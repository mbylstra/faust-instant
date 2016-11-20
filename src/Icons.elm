module Icons exposing (..)

import Svg exposing (..)
import Svg.Attributes exposing (..)
import Html.Attributes exposing (attribute)
import Html exposing (Html)


addIcon : Html msg
addIcon =
    svg [ class "add-icon", attribute "version" "1.1", viewBox "0 0 100 100", attribute "x" "0px", attribute "xmlns" "http://www.w3.org/2000/svg", attribute "xmlns:svg" "http://www.w3.org/2000/svg", attribute "y" "0px" ]
        [ g []
            [ Svg.path [ d "M 50 7 C 26.263601 7 7 26.26358 7 50 C 7 73.7364 26.263601 93 50 93 C 73.736399 93 93 73.7364 93 50 C 93 26.26358 73.736399 7 50 7 z M 50 9 C 72.655519 9 91 27.34446 91 50 C 91 72.6555 72.655519 91 50 91 C 27.344481 91 9 72.6555 9 50 C 9 27.34446 27.344481 9 50 9 z M 49.875 26.96875 A 1.0000999 1.0000999 0 0 0 49 28 L 49 49 L 28 49 A 1.0000999 1.0000999 0 0 0 27.8125 49 A 1.0043849 1.0043849 0 0 0 28 51 L 49 51 L 49 72 A 1.0000999 1.0000999 0 1 0 51 72 L 51 51 L 72 51 A 1.0000999 1.0000999 0 1 0 72 49 L 51 49 L 51 28 A 1.0000999 1.0000999 0 0 0 49.875 26.96875 z " ]
                []
            ]
        ]
