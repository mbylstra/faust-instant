port module FaustOnline exposing (Model, Msg, init, update, view, subscriptions)

import Array exposing (Array)
import String

import Html.App as App

import Html exposing
  -- delete what you don't need
  ( Html, div, span, img, p, a, h1, h2, h3, h4, h5, h6, h6, text
  , ol, ul, li, dl, dt, dd
  , form, input, textarea, button, select, option
  , table, caption, tbody, thead, tr, td, th
  , em, strong, blockquote, hr
  )
import Html.Attributes exposing
  ( style, class, id, title, hidden, type', checked, placeholder, selected
  , name, href, target, src, height, width, alt
  )
import Html.Events exposing
  ( on, targetValue, targetChecked, keyCode, onBlur, onFocus, onSubmit, onInput
  , onClick, onDoubleClick
  , onMouseDown, onMouseUp, onMouseEnter, onMouseLeave, onMouseOver, onMouseOut
  )

import Util exposing (unsafe)

import HotKeys
-- import FileReader
import Examples
import Slider
import AudioMeter
import FFTBarGraph
import Slider
import SliderNoModel
import Piano
import Color


type Polyphony
  = Monophonic
  | Polyphonic Int

-- MODEL

type alias UIInput =
  { path : String
  , value : Float
  , label : String
  }

type alias Model =
  { faustCode : String
  , compilationError : Maybe String
  , hotKeys : HotKeys.Model
  -- , fileReader : FileReader.Model
  , examples : List (String, String)
  , mainVolume : Slider.Model
  , audioMeter : AudioMeter.Model
  , fftData : List Float
  , uiInputs : Array UIInput
  , polyphony : Polyphony
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
    }
    !
    [ Cmd.map HotKeysMsg hotKeysCommand
    , elmAppInitialRender ()
    ]

showPiano : (Array UIInput) -> Bool
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
  | DSPCompiled (List String)
  | SliderChanged Int Float
  | PianoKeyMouseDown Float


createCompileCommand : Model -> Cmd Msg
createCompileCommand model =
  case model.polyphony of
    Polyphonic numVoices ->
      compileFaustCode (model.faustCode, True, numVoices)
    Monophonic ->
      compileFaustCode (model.faustCode, False, 1)

update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  -- case Debug.log "action:" action of
  case action of

    Compile ->
      model ! [ createCompileCommand model ]

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
        { model | compilationError = message } ! []

    FaustCodeChanged s ->
      { model | faustCode = s } ! []

    HotKeysMsg msg ->
      -- I think you have to get HotKeys to update the model here!
      let
        (hotKeys, hotKeysCommand) = HotKeys.update msg model.hotKeys
        -- _ = Debug.log "hotKeys" hotKeys
        commands = [ Cmd.map HotKeysMsg hotKeysCommand ] ++
          if hotKeys.controlShiftPressed
          then [ createCompileCommand model ]
          else []
      in
        { model | hotKeys = hotKeys } ! commands

    -- FileReaderMsg msg ->
    --   model ! []

    ExamplesMsg msg ->
      let
        (_, example) = Examples.update msg model.examples
        newModel = { model | faustCode = example }
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

    DSPCompiled uiInputNames ->
      let
        toUiInput rawUiInput =
          let
            label = String.split "/" rawUiInput |> Util.last |> Maybe.withDefault ""
          in
            { path = rawUiInput, value = 0.0, label = label }
        uiInputs = List.map toUiInput uiInputNames
          |> Array.fromList
      in
        { model | uiInputs = uiInputs } ! []
        -- model ! []

    SliderChanged i value ->
      let
        uiInput = unsafe (Array.get i model.uiInputs)
        uiInput' = { uiInput | value = value }
      in
        { model | uiInputs = Array.set i uiInput' model.uiInputs }
          ! [ setControlValue (uiInput.path, value) ]

    PianoKeyMouseDown pitch ->
      let
        _ = Debug.log "pitch" pitch
      in
        model ! [ setPitch pitch ]


-- VIEW

view : Model -> Html Msg
view model =

  let
    sliders =
      Array.indexedMap
      (\i uiInput -> SliderNoModel.view (SliderChanged i) uiInput.value)
      model.uiInputs
      |> Array.toList
  in
  div []
    [ div []
      [ textarea
        [ id "codemirror" ]
        -- [ onInput FaustCodeChanged ]
        -- [ text model.faustCode
        -- ]
        []
      ]
    -- , App.map FileReaderMsg (FileReader.view model.fileReader)
    , p []
        [ text (Maybe.withDefault "" model.compilationError) ]
    , button [ onClick Compile ] [ text "Compile" ]
    , App.map ExamplesMsg (Examples.view model.examples)
    , App.map VolumeSliderMsg (Slider.view model.mainVolume)
    , p []
      [ text "Audio Meter Value: "
      , text (toString model.audioMeter)
      ]
    , App.map AudioMeterMsg (AudioMeter.view model.audioMeter)
    , FFTBarGraph.view model.fftData
    , div [] sliders
    , pianoView model
    ]

pianoView : Model -> Html Msg
pianoView model =
  if showPiano (Debug.log "model.uiInputs" model.uiInputs) then
    Piano.view { blackKey = Color.black, whiteKey = Color.white} 2 36 PianoKeyMouseDown
  else
    div [] []


-- PORTS

port compileFaustCode : (String, Bool, Int) -> Cmd msg
port setControlValue : (String, Float) -> Cmd msg
port setPitch : Float -> Cmd msg
port incomingCompilationErrors : (Maybe String -> msg) -> Sub msg
port incomingFaustCode : (String -> msg) -> Sub msg
port updateFaustCode : String -> Cmd msg
port elmAppInitialRender : () -> Cmd msg
port updateMainVolume : Float -> Cmd msg
port incomingAudioMeterValue : (Float -> msg) -> Sub msg
port incomingFFTData : (List Float -> msg) -> Sub msg
port incomingDSPCompiled : (List String -> msg) -> Sub msg


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
