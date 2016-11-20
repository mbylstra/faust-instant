module ColorExtra exposing (..)

--

import Color exposing (Color, toHsl)
import List
import String


compareLightness : Color -> Color -> Order
compareLightness colorA colorB =
    let
        lightnessA =
            .lightness (toHsl colorA)

        lightnessB =
            .lightness (toHsl colorB)
    in
        if lightnessA > lightnessB then
            GT
        else if lightnessA == lightnessB then
            EQ
        else
            LT


isLighter : Color -> Color -> Bool
isLighter colorA colorB =
    case (compareLightness colorA colorB) of
        GT ->
            True

        _ ->
            False


sortByLightness : List Color -> List Color
sortByLightness colors =
    List.sortWith compareLightness colors


toCssRgb : Color -> String
toCssRgb color =
    let
        color_ =
            Color.toRgb color

        colors =
            [ color_.red
            , color_.green
            , color_.blue
            ]

        inner =
            colors
                |> List.map toString
                |> String.join ","
    in
        "rgb(" ++ inner ++ ")"
