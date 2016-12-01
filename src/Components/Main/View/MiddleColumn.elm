module Components.Main.View.MiddleColumn exposing (view)


import Json.Encode
import Html exposing (..)
import Html.Attributes exposing (..)

import HtmlHelpers exposing (aButton, maybeView, boolView)

import Components.Main.Types exposing (..)

-- component views

import Components.Main.View.BufferSnapshot as BufferSnapshot

view : Model -> Html Msg
view model =
    div [ class "middle-column" ]
        -- [ maybeView BufferSnapshot.view model.bufferSnapshot
        -- , maybeView
        [ maybeView (embedSvg "faust-svg-wrapper") model.faustSvg
        ]



embedSvg : String -> String -> Html Msg
embedSvg id svgString =
    div
        [ property "innerHTML" <| Json.Encode.string svgString ]
        []
