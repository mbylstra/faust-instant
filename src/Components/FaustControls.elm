module Components.FaustControls exposing (..)

import Json.Decode exposing (..)

import String
import Array exposing (Array)

import Util exposing (unsafeResult)

type alias SliderData =
  { address: String
  , init: Float
  , label: String
  , max: Float
  , min: Float
  , step: Float
  , type': String
  }

showPiano : (Array SliderData) -> Bool
showPiano uiInputs =
  uiInputs
  |> Array.filter (\uiInput -> uiInput.label == "freq")
  |> Array.length
  |> (==) 1

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
