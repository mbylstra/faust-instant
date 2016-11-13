module Main exposing (..)

import Html.App

import Components.Main.Model
import Components.Main.Update
import Components.Main.View
import Components.Main.Subscriptions
import Components.Main.Types

import Stylesheets exposing (cssFiles)

import Util exposing (last)

main : Program Never
main =
  Html.App.program
    { init = Components.Main.Model.init
    , update = Components.Main.Update.update
    , view = Components.Main.View.view
    , subscriptions = subscriptions
    }



subscriptions : Components.Main.Types.Model -> Sub Components.Main.Types.Msg
subscriptions model =
  Sub.batch (Components.Main.Subscriptions.subscriptions model)
