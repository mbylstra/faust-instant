module FaustControls exposing (..)

import Json.Decode exposing (..)

import Util exposing (unsafeResult)
import String

type alias SliderData =
  { address: String
  , init: Float
  , label: String
  , max: Float
  , min: Float
  , step: Float
  , type': String
  }

unsafeStringToFloat : String -> Float
unsafeStringToFloat s =
  s |> String.toFloat |> unsafeResult


sliderDecoder : Decoder SliderData
sliderDecoder =
    object7 SliderData
      ("address" := string)
      ("init" := map unsafeStringToFloat string)
      ("label" := string)
      ("max" := map unsafeStringToFloat string)
      ("min" := map unsafeStringToFloat string)
      ("step" := map unsafeStringToFloat string)
      ("type" := string)
