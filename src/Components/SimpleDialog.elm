module Components.SimpleDialog exposing (Model, init, view, update, Msg(Open, Close))

import HtmlHelpers exposing (maybeHtml, emptyHtml)
import HtmlHelpers.Events exposing (stopClickPropagation)

import Html exposing
  -- delete what you don't need
  ( Html, div, span, img, p, a, h1, h2, h3, h4, h5, h6, h6, text
  -- , ol, ul, li, dl, dt, dd
  -- , form, input, textarea, button, select, option
  -- , table, caption, tbody, thead, tr, td, th
  -- , em, strong, blockquote, hr
  )
-- import Html.Attributes exposing
--   ( style, id, title, hidden, type', checked, placeholder, selected
-- --   , name, href, target, src, height, width, alt
--   )
import Html.Events exposing
  ( on, targetValue, targetChecked, keyCode, onBlur, onFocus, onSubmit
  , onClick
  )


import Components.SimpleDialog.Stylesheet exposing (..)



-- MODEL

type alias Model =
  { isOpen : Bool
  }

init : Model
init =
  { isOpen = False
  }


-- UPDATE

type Msg
  = Open
  | Close
  | NoOp

-- TODO: we might want a way to notify the parent that the modeal has been
-- closed? In which case, we might want an OutMsg

-- TODO: we need a way to open the thing! Still not really clear what the
-- best approach is - perhaps just expose the Open Msg and have the parent
-- use it to update the child OR expose a method
update : Msg -> Model -> Model
update msg model =
  case Debug.log "msg" msg of
    Open ->
      { model | isOpen = True }
    Close ->
      { model | isOpen = False }
    NoOp ->
      model

open : Model -> Model
open model =
  { model | isOpen = True }


-- VIEW

-- So, this way the parent can determine if the child is open or closed,
-- But it has no way of responding to the close event

type alias Config parentMsg =
  { toMsg : Model -> parentMsg
  }


-- view : Config parentMsg -> Model -> Html parentMsg
-- view config model =
--   if model.isOpen then
--     ( span
--       [ onClick (config.toMsg model)]
--       [ ]
--     )
--   else
--     emptyHtml

view : (Msg -> parentMsg) -> Html parentMsg -> Model -> Html parentMsg
view tagger html model =
    -- div [] [ text "wtf" ]
  if Debug.log "model.isOpen" model.isOpen then
    let
      body = html
      backdropAttrs =
        [ class [Backdrop], onClick <| tagger Close ]
    in
      div
        backdropAttrs
        [ div
          [ class [Modal]
          , stopClickPropagation <| tagger NoOp
          ]
          [ body
          ]
        ]
  else
    -- div [] [ text "wtf" ]
    emptyHtml


-- Idea you package this msg inside the parentMsg,
-- and then the parent just passes it back down to
-- here

-- bodyView : (Msg -> parentMsg) -> List (Html parentMsg) -> Html parentMsg
-- bodyView tagger html =
--   div
--     -- [ class "modal-body",]
--     [ stopClickPropagation <| tagger NoOp]
--     -- [ stopClickPropagation NoOp]
--
--     -- []
--     -- [ class "modal-body", stopClickPropagation NoOp]
--
--     html


-- What the fuck is this?
-- Looks like a dirty native hack to do something that's not possible
-- in pure elm!
-- https://github.com/evancz/elm-sortable-table/blob/1.0.0/src/Table.elm#L479
-- Actually, I think it's good evidence that not having an update function
-- is a bad idea!
