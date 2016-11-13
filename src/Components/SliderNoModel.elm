module Components.SliderNoModel exposing (view)

import String

import Html exposing (Html, Attribute, div, input)
import Html.Attributes exposing (class, type', value)
import Html.Events exposing (on, targetValue)

import Json.Decode
import Result


-- VIEW

view : { min: Float, max: Float, step: Float} -> (Float -> msg) -> Float -> Html msg
view attrs tagger model =
  input
    [ type' "range"
    , Html.Attributes.min (toString attrs.min)
    , Html.Attributes.max (toString attrs.max)
    , Html.Attributes.step (toString attrs.step)
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
