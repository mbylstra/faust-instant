module ProgramList exposing (Model, Msg, init, update, view)

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
import FaustProgram
import Main.Http.Firebase

-- MODEL

type alias Model =
  { demos: List FaustProgram.Model
  , myPrograms: List FaustProgram.Model
  }

init : (Model, Cmd Msg)
init =
  let
    cmd = Task.perform Error FetchedStaffPicks Main.Http.Firebase.getStaffPicks
  in
    { demos = [], myPrograms = [] } ! [ cmd ]

-- UPDATE

type Msg
  = Error (HttpBuilder.Error String)
  | FetchedStaffPicks (List (String, FaustProgram.Model))
  | OpenProgram FaustProgram.Model

update : Msg -> Model -> (Model, Cmd Msg, Maybe FaustProgram.Model)
update action model =
  case action of

    Error e ->
      let
        _ = Debug.crash (toString e)
      in
        (model, Cmd.none, Nothing)

    FetchedStaffPicks staffPicks ->
      let
        newModel = { model | demos = List.map snd staffPicks }
      in
        (newModel, Cmd.none, Nothing)

    OpenProgram faustProgram ->
        (model, Cmd.none, Just faustProgram)


-- VIEW

buttonView : FaustProgram.Model -> Html Msg
buttonView faustProgram =
  button
    [ class "example", onClick (OpenProgram faustProgram) ]
    [ text faustProgram.title ]

view : Bool -> Model -> Html Msg
view loggedIn model =
  let
    buttons = List.map buttonView model.demos
  in
    if loggedIn
    then
      div [] (buttons ++ [ div [] [ text "logged in"]]) 
    else
      div [] buttons
