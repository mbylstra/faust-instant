module Components.Main.View.BufferSnapshot exposing (..)

import Svg
-- import Svg.Attributes
import Plot exposing (..)



view : List Float -> Svg.Svg msg
view bufferSnapshot =
    let
        data = List.indexedMap (\x y -> (toFloat x, y)) bufferSnapshot
    in
        plot
            [ size ( 4000, 180 ) ]
            [ line
                [ lineStyle
                    [ ( "stroke", "#666" )
                    , ( "stroke-width", "0.5" )
                    ]
                ]
                data
            , scatter
                [ scatterStyle
                    [ ( "fill", "#CCC" )
                    ]
                , scatterRadius 1.5
                ]
                data
            ]

text : List Float -> String
text data =
    data
    |> List.map toString
    |> String.join ", "
