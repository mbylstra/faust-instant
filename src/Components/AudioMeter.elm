module Components.AudioMeter exposing (Model, Msg(Updated), init, update, view)

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


-- MODEL

type alias Model = Float

init : Model
init = 0.0


-- UPDATE

type Msg
  = Updated Float

update : Msg -> Model -> Model
update action model =
  case action of
    Updated v -> v


-- VIEW

view : Model -> Html Msg
view model =
  let
    cssHeight =
      if model < 1.0 then
        toString(round (model * 100.0)) ++ "%"
      else
        "100%"
  in
    div
      [ class "audio-meter"  ]
      [ div
        [ class "audio-meter-bar"
        , style [("height", cssHeight)]
        ]
        [ ]
      ]
