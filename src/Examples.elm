module Examples exposing (Model, Msg, update, init, view)

import Http
import Task exposing (Task)

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


-- MODEL

type alias Model = List (String, String)

examples : Model
examples =
  [ ("Kisana", "Kisana.dsp")
  , ("Spooky Slide Whistle", "spooky-slide-whistle.dsp")
  , ("Flappy Flute", "FlappyFlute.dsp")
  , ("Birds", "Birds.dsp")
  ]
init : Model
init = examples


-- UPDATE

type Msg
  = ExampleSelected (String, String)
  | ExampleFetched String
  | ErrorFetchingExample Http.Error


fetchExample : String -> Task Http.Error String
fetchExample filename =
  Http.getString ("faust-examples/" ++ filename)

update :
    Msg
    -> Model
    -> { model : Model, cmd: Cmd Msg, code : Maybe String }
update action model =
  case action of
    ExampleSelected (title, filename) ->
      { model = model
      , cmd = Task.perform (\e -> ErrorFetchingExample e) ExampleFetched (fetchExample filename)
      , code = Nothing
      }
    ExampleFetched code ->
      { model = model
      , cmd = Cmd.none
      , code = Just code
      }
    ErrorFetchingExample e ->
      Debug.crash ("Error fetching example: " ++ (toString e))


-- getMeetupEventsCmd =
--
-- getEvents : Task Http.Error (List MeetupEvent)
-- getEvents =
--     Http.get eventsDecoder eventsUrl

-- VIEW

buttonView : (String, String) -> Html Msg
buttonView (name, example) =
  button
    [ class "example", onClick (ExampleSelected (name, example)) ]
    [ text name ]

view : Model -> Html Msg
view model =
  let
    buttons = List.map buttonView model
  -- let
  --   List.map (\(key, value) ->
  in
    div [] buttons
