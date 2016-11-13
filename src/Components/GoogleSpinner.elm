module Components.GoogleSpinner exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing ( attribute, style, id )

import Svg exposing ( Svg, svg, node)
import Svg.Attributes exposing (viewBox, fill, class)

{- from https://codepen.io/jczimm/pen/vEBpoL -}
view : Html msg
view =
  -- div [ id "spinner", class "google-spinner", style [("display", "none")] ]
  div [ id "spinner", class "google-spinner" ]
    [ svg [ class "google-spinner__circular", viewBox "25 25 50 50" ]
      [ node "circle"
        [ class "google-spinner__path"
        , attribute "cx" "50"
        , attribute "cy" "50"
        , fill "none"
        , attribute "r" "20"
        ]
        []
      ]
    ]
