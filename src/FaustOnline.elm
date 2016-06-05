port module FaustOnline exposing (Model, Msg, init, update, view, subscriptions)

import Html exposing
  -- delete what you don't need
  ( Html, div, span, img, p, a, h1, h2, h3, h4, h5, h6, h6, text
  , ol, ul, li, dl, dt, dd
  , form, input, textarea, button, select, option
  , table, caption, tbody, thead, tr, td, th
  , em, strong, blockquote, hr
  )
-- import Html.Attributes exposing
--   ( style, class, id, title, hidden, type', checked, placeholder, selected
--   , name, href, target, src, height, width, alt
--   )
import Html.Events exposing
  ( on, targetValue, targetChecked, keyCode, onBlur, onFocus, onSubmit, onInput
  , onClick, onDoubleClick
  , onMouseDown, onMouseUp, onMouseEnter, onMouseLeave, onMouseOver, onMouseOut
  )

import HotKeys


-- MODEL

type alias Model =
  { faustCode : String
  , compilationError : Maybe String
  , hotKeys : HotKeys.Model
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
    }
    !
    [ Cmd.map HotKeysMsg hotKeysCommand ]


-- UPDATE

type Msg
  = Compile
  | CompilationError (Maybe String)
  | FaustCodeChanged String
  | HotKeysMsg HotKeys.Msg

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

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ div []
      [ textarea
        [ onInput FaustCodeChanged ]
        [ text model.faustCode
        ]
      ]
    , p []
        [ text (Maybe.withDefault "" model.compilationError) ]
    , button [ onClick Compile ] [ text "Compile" ]
    ]

-- PORTS

port compileFaustCode : String -> Cmd msg

port incomingCompilationErrors : (Maybe String -> msg) -> Sub msg


-- SUBSCRIPTIONS
subscriptions : List (Sub Msg)
subscriptions =
  [ incomingCompilationErrors CompilationError
  , Sub.map HotKeysMsg HotKeys.subscription
  ]
