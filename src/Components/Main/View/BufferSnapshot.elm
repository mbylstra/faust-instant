module Components.Main.View.BufferSnapshot exposing (..)

import Svg
-- import Svg.Attributes
import Plot exposing (..)



data1 : List ( Float, Float )
data1 =
    [ ( 0, 8 ), ( 1, 13 ), ( 2, 14 ), ( 3, 12 ), ( 4, 11 ), ( 5, 16 ), ( 6, 22 ), ( 7, 32 ), ( 8, 36 ) ]


view : List Float -> Svg.Svg msg
view bufferSnapshot =
    let
        data = List.indexedMap (\x y -> (toFloat x, y)) bufferSnapshot
    in
        plot
            [ size ( 600, 50 ) ]
            [ line
                [ lineStyle
                    [ ( "stroke", "white" )
                    , ( "stroke-width", "1px" )
                    ]
                ]
                data
            -- , xAxis
            --     -- [ axisStyle [ ( "stroke", Colors.axisColor ) ]
            --     []
            ]
