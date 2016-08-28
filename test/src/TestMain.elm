module TestMain exposing (Model, Msg, init, update, view)

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
  ( on, targetValue, targetChecked, keyCode, onBlur, onFocus, onSubmit
  , onClick, onDoubleClick
  , onMouseDown, onMouseUp, onMouseEnter, onMouseLeave, onMouseOver, onMouseOut
  )


import Task

import HttpBuilder

-- import Main.Model as Model
import FaustProgram

import FirebaseRest exposing (getOne, getMany)

-- MODEL

type alias Model =
  { faustPrograms : List (String, FaustProgram.Model)
  }

-- getOne :
--   String
--   -> String
--   -> Json.Decode.Decoder model
--   -> Maybe String
--   -> Task (HttpBuilder.Error String) model
-- getOne databaseUrl path decoder maybeAuthToken =

databaseUrl : String
databaseUrl = "https://faust-instant.firebaseio.com"

getOneTask =
  getOne databaseUrl "faustPrograms/-KQAR9MLgqaLBz2NUMOJ" FaustProgram.decoder Nothing
getManyTask =
  getMany databaseUrl "faustPrograms" FaustProgram.decoder Nothing

init : (Model, Cmd Msg)
init =
  { faustPrograms = []
  }
  !
  [ Task.perform Error FetchedFaustProgram getOneTask
  , Task.perform Error FetchedFaustProgramList getManyTask
  ]


-- UPDATE

type Msg
  = Error (HttpBuilder.Error String)
  | FetchedFaustProgram FaustProgram.Model
  | FetchedFaustProgramList (List (String, FaustProgram.Model))

update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    Error e ->
      let
        _ = Debug.crash (toString e)
      in
        model ! []

    FetchedFaustProgram faustProgram ->
      let
        _ = Debug.log "faustProgram" faustProgram
      in
        model ! []

    FetchedFaustProgramList faustPrograms ->
      let
        _ = Debug.log "faustProgramList" faustPrograms
      in
        { model | faustPrograms = faustPrograms } ! []

-- VIEW

view : Model -> Html Msg
view model =
  let
    renderFaustProgram (id, fp) =
      div [] [ text (toString fp.authorUid)]
  in
  div
    []
    (List.map renderFaustProgram model.faustPrograms)
