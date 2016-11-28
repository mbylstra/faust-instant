module Components.Main.View.KnobsAndSliders exposing (view)

import Array

import Html exposing (..)
import Html.Attributes exposing (..)

import Components.SliderNoModel as SliderNoModel

import Components.Main.Types exposing (..)

view : Model -> Html Msg
view model =
    let
        sliders =
            let
                renderSlider i uiInput =
                    label [ class "slider-container" ]
                        [ SliderNoModel.view
                            { min = uiInput.min, max = uiInput.max, step = uiInput.step }
                            (SliderChanged i)
                            uiInput.init
                        , span [] [ text uiInput.label ]
                        ]
            in
                Array.indexedMap renderSlider model.uiInputs |> Array.toList
    in
        div [ class "sliders" ] sliders
