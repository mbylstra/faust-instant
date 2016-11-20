module Components.Main.View.UserMenu exposing (..)

import Material.Menu as Menu exposing (Item, bottomRight, onSelect)
import Html exposing (Html, text)
import Html.Events exposing (onClick)


-- import Html.App as App

import Components.Main.Types exposing (Msg(MenuMsg, LogOutClicked, OpenUserSettingsDialog))


-- Is this an Elm compiler bug? It seems impossible to annotate this type,
-- because Material.Menu does not expose the Container type. The suggestion
-- that the compiler makes will not compile.
-- Well, it seems possible, as it's just a type aliase, so you can redefine
-- the type alias here. Pretty ugly though.
-- type alias Container c =
--   { c | menu : Indexed Model }
-- view
--     :  (Msg Menu.Container c) -> Msg)
--     -> Index
--     -> Container c
--     -> Html m


view mdlMsg mdlModel =
    Menu.render mdlMsg
        [ 0 ]
        mdlModel
        [ Menu.bottomRight
          -- , Menu.ripple
        ]
        [ Menu.item
            [ onSelect OpenUserSettingsDialog ]
            [ text "Edit Profile" ]
        , Menu.item
            [ onSelect LogOutClicked ]
            [ text "Log Out" ]
        ]
