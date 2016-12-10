module Components.Main.View.MiddleColumn exposing (view)


import Html exposing (..)
import Html.Attributes exposing (..)

import HtmlHelpers exposing (aButton, maybeView, boolView)

import Components.Main.Types exposing (..)

-- component views

import Components.Main.View.BufferSnapshot as BufferSnapshot


view : Model -> Html Msg
view model =
    div [ class "middle-column" ]
        [ maybeView svgView model.faustSvgUrl
        , maybeView bufferSnapshotView model.bufferSnapshot
        ]


svgView : String -> Html Msg
svgView url =
    iframe
        [ src url
        , style
            [ ("background-color", "black")
            , ("border", "0")
            ]
        ]
        [ ]


bufferSnapshotView : List Float -> Html Msg
bufferSnapshotView bufferSnapshot =
    div
        [ class "buffer-snapshot-holder" ]
        [ div [ class "buffer-snapshot-inner"]
            [ BufferSnapshot.view bufferSnapshot
            , text <| BufferSnapshot.text bufferSnapshot
            ]
        ]





-- embedSvg : String -> String -> Html Msg
-- embedSvg id svgString =
--     div
--         [ property "innerHTML" <| Json.Encode.string svgString
--         ]
--         []
