module Components.FaustControls exposing (..)

import Json.Decode exposing (..)
import String
import Array exposing (Array)
import Util exposing (unsafeResult)


-- showPiano : Array SliderData -> Bool
-- showPiano uiInputs =
--     uiInputs
--         |> Array.filter (\uiInput -> uiInput.label == "freq")
--         |> Array.length
--         |> (==) 1
