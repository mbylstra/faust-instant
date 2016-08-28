module Main.View.ProgramList exposing (view)

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
import Main.Types exposing (..)

import FaustProgram

import Main.Model exposing (isLoggedIn)



-- VIEW

buttonView : FaustProgram.Model -> Html Msg
buttonView faustProgram =
  button
    [ class "example", onClick (OpenProgram faustProgram) ]
    [ text faustProgram.title ]

view : Model -> Html Msg
view model =
  let
    buttons = List.map buttonView model.staffPicks
  in
    if (isLoggedIn model)
    then
      div [] (buttons ++ [ div [] [ text "logged in"]])
    else
      div [] buttons
