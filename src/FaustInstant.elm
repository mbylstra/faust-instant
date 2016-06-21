port module FaustInstant exposing (Model, Msg, init, update, view, subscriptions)

import Array exposing (Array)
import String
-- import String.Addons as StringAddons

import Html.App as App

import Html exposing
  -- delete what you don't need
  ( Html, div, span, img, p, a, h1, h2, h3, h4, h5, h6, h6, text
  , ol, ul, li, dl, dt, dd
  , form, input, textarea, button, select, option
  , table, caption, tbody, thead, tr, td, th
  , em, strong, blockquote, hr, label
  )
import Html.Attributes exposing
  ( style, class, id, title, hidden, type', checked, placeholder, selected
  , name, href, target, src, height, width, alt, value
  )
import Html.Events exposing
  ( on, targetValue, targetChecked, keyCode, onBlur, onFocus, onSubmit, onInput
  , onClick, onDoubleClick
  , onMouseDown, onMouseUp, onMouseEnter, onMouseLeave, onMouseOver, onMouseOut
  )
import Json.Decode

import Util exposing (unsafeMaybe, unsafeResult)

import HotKeys
-- import FileReader
import Examples
import Slider
import AudioMeter
-- import FFTBarGraph
import Slider
import SliderNoModel
import Piano
import Color
import GoogleSpinner
import FaustControls

type Polyphony
  = Monophonic
  | Polyphonic Int


bufferSizes : List Int
bufferSizes =
  [ 256, 512, 1024, 2048, 4096 ]  -- Note web audio requires a minimum of 256

defaultBufferSize : Int
defaultBufferSize = 512

sampleRate : Float
sampleRate = 44100.0

getBufferSizeMillis : Int -> Int
getBufferSizeMillis bufferSize =
  Basics.round ((1.0 / sampleRate) * (toFloat bufferSize) * 1000.0)

-- MODEL

type alias Model =
  { faustCode : String
  , compilationError : Maybe String
  , hotKeys : HotKeys.Model
  -- , fileReader : FileReader.Model
  , examples : List (String, String)
  , mainVolume : Slider.Model
  , audioMeter : AudioMeter.Model
  , fftData : List Float
  , uiInputs : Array (FaustControls.SliderData)
  , polyphony : Polyphony
  , bufferSize : Int
  , loading : Bool
  }

init : (Model, Cmd Msg)
init =
  let
    (hotKeys, hotKeysCommand) = HotKeys.init
  in
    { faustCode = """import("music.lib");
process = noise;
"""
    , compilationError = Nothing
    , hotKeys = hotKeys
    -- , fileReader = FileReader.init
    , examples = Examples.init
    , mainVolume = Slider.init 1.0
    , audioMeter = AudioMeter.init
    , fftData = []
    , uiInputs = Array.empty
    , polyphony = Monophonic
    , bufferSize = defaultBufferSize
    , loading = False
    }
    !
    [ Cmd.map HotKeysMsg hotKeysCommand
    , elmAppInitialRender ()
    ]

showPiano : (Array FaustControls.SliderData) -> Bool
showPiano uiInputs =
  uiInputs
  |> Array.filter (\uiInput -> uiInput.label == "freq")
  |> Array.length
  |> (==) 1


-- UPDATE

type Msg
  = Compile
  | CompilationError (Maybe String)
  | FaustCodeChanged String
  | HotKeysMsg HotKeys.Msg
  -- | FileReaderMsg FileReader.Msg
  | ExamplesMsg Examples.Msg
  | VolumeSliderMsg Slider.Msg
  | AudioMeterMsg AudioMeter.Msg
  | NewFFTData (List Float)
  | DSPCompiled (List Json.Decode.Value)
  | SliderChanged Int Float
  | PianoKeyMouseDown Float
  | BufferSizeChanged Int


createCompileCommand : Model -> Cmd Msg
createCompileCommand model =
  case model.polyphony of
    Polyphonic numVoices ->
      compileFaustCode
        { faustCode = model.faustCode, polyphonic = True
        , numVoices = numVoices, bufferSize = model.bufferSize
        }
    Monophonic ->
      compileFaustCode
        { faustCode = model.faustCode, polyphonic = False
        , numVoices = 1, bufferSize = model.bufferSize
        }

update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  -- case Debug.log "action:" action of
  case action of

    Compile ->
      { model | loading = True } ! [ createCompileCommand model ]

    CompilationError maybeRawMessage ->
      let
        message = case maybeRawMessage of
          Just rawMessage ->
            rawMessage
            -- |> String.dropLeft 6
            -- |> String.dropLeft 6
            |> Just
          Nothing ->
            Nothing
      in
        { model | compilationError = message, loading = False } ! []

    FaustCodeChanged s ->
      { model | faustCode = s } ! []

    HotKeysMsg msg ->
      -- I think you have to get HotKeys to update the model here!
      let
        (hotKeys, hotKeysCommand) = HotKeys.update msg model.hotKeys
        -- _ = Debug.log "hotKeys" hotKeys
        doCompile = hotKeys.controlShiftPressed
        commands = [ Cmd.map HotKeysMsg hotKeysCommand ] ++
          if doCompile
          then [ createCompileCommand model ]
          else []
        loading = if doCompile then True else model.loading
      in
        { model | hotKeys = hotKeys, loading = loading } ! commands

    -- FileReaderMsg msg ->
    --   model ! []

    ExamplesMsg msg ->
      let
        (_, example) = Examples.update msg model.examples
        newModel = { model | faustCode = example, loading = True }
      in
        newModel
          ! [ createCompileCommand newModel
            , updateFaustCode newModel.faustCode
            ]

    VolumeSliderMsg msg ->
      let
        newModel = { model | mainVolume = Slider.update msg model.mainVolume }
      in
        newModel ! [ updateMainVolume newModel.mainVolume ]

    AudioMeterMsg msg ->
      { model | audioMeter = AudioMeter.update msg model.audioMeter } ! []

    NewFFTData fftData ->
      { model | fftData = fftData } ! []

    DSPCompiled jsonList ->
      let
        decodeJson json =
          json
          |> Json.Decode.decodeValue FaustControls.sliderDecoder
          |> unsafeResult
        sliders = List.map decodeJson jsonList |> Array.fromList
      in
        { model | uiInputs = sliders, loading = False } ! []
        -- Debug.log "newmodel" { model | uiInputs = uiInputs } ! []
        -- model ! []

    SliderChanged i value ->
      let
        uiInput = unsafeMaybe (Array.get i model.uiInputs)
        uiInput' = { uiInput | init = value }
      in
        { model | uiInputs = Array.set i uiInput' model.uiInputs }
          ! [ setControlValue (uiInput.address, value) ]

    PianoKeyMouseDown pitch ->
      let
        _ = Debug.log "pitch" pitch
      in
        model ! [ setPitch pitch ]

    BufferSizeChanged bufferSize ->
      let
        newModel = { model | bufferSize = bufferSize }
      in
        newModel ! [ createCompileCommand newModel ]


-- VIEW

view : Model -> Html Msg
view model =

  let
    sliders =
      let
        renderSlider i uiInput =
          label [ class "slider-container" ]
            [ SliderNoModel.view
                { min = uiInput.min, max = uiInput.max, step = uiInput.step }
                (SliderChanged i)
                uiInput.init
            , span [] [text uiInput.label]
            ]
      in
        Array.indexedMap renderSlider model.uiInputs |> Array.toList
  in
  div [ class "main-wrap" ]
    [ div [ class "main-header" ]
      [ h1 [] [ text "Faust Instant" ] ]
    , div [ class "main-row" ]
      [ div [ class "code-editor-column" ]
        [ div [ class "code-editor"]
          [ textarea
            [ id "codemirror" ]
            []
          ]
        , div [ class "code-editor-buttons" ]
          [ div [ class "spinner-holder" ]
              [ if model.loading then GoogleSpinner.view else span [] [] ]
          , label [] [ text "Latency"]
          , bufferSizeSelectView model
          , button [ onClick Compile ]
            [ text "Compile "
            , span [] [ text "(CTRL-ENTER)" ]
            ]
          ]
        ]
      , div [ class "examples"]
        [ App.map ExamplesMsg (Examples.view model.examples) ]
      ]
    , div [ class "main-footer" ]
      [ p []
          [ text (Maybe.withDefault "" model.compilationError) ]
      -- , App.map VolumeSliderMsg (Slider.view model.mainVolume)
      -- , p []
      --   [ text "Audio Meter Value: "
      --   , text (toString model.audioMeter)
      --   ]
      -- , App.map AudioMeterMsg (AudioMeter.view model.audioMeter)
      -- , FFTBarGraph.view model.fftData
      , div [ class "sliders" ] sliders
      , pianoView model
      ]
    ]

pianoView : Model -> Html Msg
pianoView model =
  if showPiano model.uiInputs then
    Piano.view { blackKey = Color.black, whiteKey = Color.white} 2 36 PianoKeyMouseDown
  else
    div [] []

bufferSizeSelectView : Model -> Html Msg
bufferSizeSelectView model =
  let
    renderOption bufferSize =
      option
        [ value (toString bufferSize), selected (bufferSize == model.bufferSize)]
        [ text ((toString (getBufferSizeMillis bufferSize)) ++ "ms") ]
    parseInt s =
      String.toInt s |> Result.toMaybe |> Maybe.withDefault defaultBufferSize

    onChange =
      on "change" (Json.Decode.map (\v -> BufferSizeChanged (parseInt v)) targetValue)
  in
    select
      [ onChange ]
      (List.map renderOption bufferSizes)


-- PORTS


port compileFaustCode :
  { faustCode: String, polyphonic: Bool, numVoices: Int, bufferSize: Int }
  -> Cmd msg
port setControlValue : (String, Float) -> Cmd msg
port setPitch : Float -> Cmd msg
port incomingCompilationErrors : (Maybe String -> msg) -> Sub msg
port incomingFaustCode : (String -> msg) -> Sub msg
port updateFaustCode : String -> Cmd msg
port elmAppInitialRender : () -> Cmd msg
port updateMainVolume : Float -> Cmd msg
port incomingAudioMeterValue : (Float -> msg) -> Sub msg
port incomingFFTData : (List Float -> msg) -> Sub msg
port incomingDSPCompiled : (List Json.Decode.Value -> msg) -> Sub msg


-- SUBSCRIPTIONS
subscriptions : List (Sub Msg)
subscriptions =
  [ incomingFaustCode FaustCodeChanged
  , incomingCompilationErrors CompilationError
  , Sub.map AudioMeterMsg (incomingAudioMeterValue AudioMeter.Updated)
  , Sub.map HotKeysMsg HotKeys.subscription
  , incomingFFTData NewFFTData
  , incomingDSPCompiled DSPCompiled
  ]
