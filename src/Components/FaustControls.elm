module Components.FaustControls exposing (..)

import Json.Decode exposing (..)
import String
import Array exposing (Array)
import Util exposing (unsafeResult)


type alias SliderData =
    { address : String
    , init : Float
    , label : String
    , max : Float
    , min : Float
    , step : Float
    , type_ : String
    }


showPiano : Array SliderData -> Bool
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
    map7 SliderData
        (field "address" string)
        (field "init" (map unsafeStringToFloat string))
        (field "label" string)
        (field "max" (map unsafeStringToFloat string))
        (field "min" (map unsafeStringToFloat string))
        (field "step" (map unsafeStringToFloat string))
        (field "type" string)
