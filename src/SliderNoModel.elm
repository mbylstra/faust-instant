module SliderNoModel exposing (view)

import String

import Html exposing (Html, Attribute, div, input)
import Html.Attributes exposing (class, type', value)
import Html.Events exposing (on, targetValue)

import Json.Decode
import Result


-- VIEW

view : (Float -> msg) -> Float -> Html msg
view tagger model =
  input
    [ type' "range"
    , Html.Attributes.min "0"
    , Html.Attributes.max "1"
    , Html.Attributes.step "0.001"
    , value (toString model)
    , onSliderInput tagger
    ]
    []


onSliderInput : (Float -> msg) -> Attribute msg
onSliderInput tagger =
  let
    mapper = decodeSliderValue >> tagger
  in
    on
      "input"
      (Json.Decode.map mapper targetValue)


decodeSliderValue : String -> Float
decodeSliderValue result =
  ( result
    |> String.toFloat
    |> Result.withDefault 0.0
  )
