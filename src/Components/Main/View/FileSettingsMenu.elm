module Components.Main.View.FileSettingsMenu exposing (..)

import Material.Menu as Menu exposing (Item, bottomRight, onSelect)
import Material.Options as Options

import Html exposing (Html, text)
import Html.Events exposing (onClick)
-- import Html.App as App

import Components.Main.Types exposing
  (Msg( MenuMsg
      , LogOutClicked
      , OpenUserSettingsDialog
      , DeleteCurrentFile)
  )

view mdlMsg mdlModel =
  Menu.render mdlMsg [1] mdlModel
    [ Menu.bottomRight
    -- , Menu.ripple
    , Menu.icon "settings"
    ]
    [ Menu.item
      [ onSelect DeleteCurrentFile ]
      [ text "Delete" ]
    ]


    -- [ Menu.Item False True
    --   <| Html.div [ onClick OpenUserSettingsDialog ] [ Html.text "Blah" ]
    -- , Menu.Item False True
    --   <| Html.div [ onClick LogOutClicked ] [ Html.text "Blah2" ]
    -- ]
    -- [ ]
