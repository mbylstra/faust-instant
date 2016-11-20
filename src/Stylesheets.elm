port module Stylesheets exposing (..)

import Css.File exposing (..)
import Html exposing (div)


import Components.SimpleDialog.Stylesheet as SimpleDialogStylesheet


port files : CssFileStructure -> Cmd msg


cssFiles : CssFileStructure
cssFiles =
    toFileStructure [ ( "main.css", compile [ SimpleDialogStylesheet.css ] ) ]


main : Program Never () msg
main =
    Html.program
        { init = ( (), files cssFiles )
        , view = \_ -> (div [] [])
        , update = \_ _ -> ( (), Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
