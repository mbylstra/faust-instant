module Main.View.UserSettingsDialog exposing (view)

import Html exposing (Html)
import Html.App as App

import HtmlHelpers exposing (maybeView, emptyHtml)

import SimpleDialog

import Main.Types exposing (Model, Msg(UserSettingsFormMsg, UserSettingsDialogMsg))
import UserSettingsForm

import Util exposing (unsafeMaybe)

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


view : Main.Types.Model -> Html Msg
view model =
  case model.user of
    Just user ->
      case model.userSettingsForm of
        Just userSettingsForm ->
          let
            innerHtml = UserSettingsForm.view userSettingsForm |> App.map UserSettingsFormMsg
          in
            SimpleDialog.view UserSettingsDialogMsg innerHtml model.userSettingsDialog
        Nothing ->
          emptyHtml
    Nothing ->
      emptyHtml
