port module FaustOnline exposing (Model, Msg, init, update, view, subscriptions)

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

import HotKeys
import FileReader
import Examples
import Slider


-- MODEL

type alias Model =
  { faustCode : String
  , compilationError : Maybe String
  , hotKeys : HotKeys.Model
  , fileReader : FileReader.Model
  , examples : List (String, String)
  , mainVolume : Slider.Model
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
    , fileReader = FileReader.init
    , examples = Examples.init
    , mainVolume = Slider.init 1.0
    }
    !
    [ Cmd.map HotKeysMsg hotKeysCommand
    , elmAppInitialRender ()
    ]


-- UPDATE

type Msg
  = Compile
  | CompilationError (Maybe String)
  | FaustCodeChanged String
  | HotKeysMsg HotKeys.Msg
  | FileReaderMsg FileReader.Msg
  | ExamplesMsg Examples.Msg
  | VolumeSliderMsg Slider.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case Debug.log "action:" action of

    Compile ->
      model ! [ compileFaustCode model.faustCode ]

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
        _ = Debug.log "hotKeys" hotKeys
        commands = [ Cmd.map HotKeysMsg hotKeysCommand ] ++
          if hotKeys.controlShiftPressed
          then [ compileFaustCode model.faustCode ]
          else []
      in
        { model | hotKeys = hotKeys } ! commands

    FileReaderMsg msg ->
      model ! []

    ExamplesMsg msg ->
      let
        (_, example) = Examples.update msg model.examples
        newModel = { model | faustCode = example }
      in
        newModel
          ! [ compileFaustCode newModel.faustCode
            , updateFaustCode newModel.faustCode
            ]

    VolumeSliderMsg msg ->
      let
        newModel = { model | mainVolume = Slider.update msg model.mainVolume }
      in
        newModel ! [ updateMainVolume newModel.mainVolume ]


-- VIEW

view : Model -> Html Msg
view model =
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
    ]

-- PORTS

port compileFaustCode : String -> Cmd msg
port incomingCompilationErrors : (Maybe String -> msg) -> Sub msg
port incomingFaustCode : (String -> msg) -> Sub msg
port updateFaustCode : String -> Cmd msg
port elmAppInitialRender : () -> Cmd msg
port updateMainVolume : Float -> Cmd msg


-- SUBSCRIPTIONS
subscriptions : List (Sub Msg)
subscriptions =
  [ incomingFaustCode FaustCodeChanged
  , incomingCompilationErrors CompilationError
  , Sub.map HotKeysMsg HotKeys.subscription
  ]
