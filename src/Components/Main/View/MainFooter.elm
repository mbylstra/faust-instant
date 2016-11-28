module Components.Main.View.MainFooter exposing (view)

-- core

import Color
import Json.Encode


-- html

import Html exposing (..)
import Html.Attributes exposing (..)

-- external libs

import HtmlHelpers exposing (aButton, maybeView, boolView)

-- external components

-- project components

import Components.Piano as Piano
import Components.FaustControls as FaustControls


-- import FaustProgram

import Components.Main.Types exposing (..)
import Components.FaustControls as FaustControls

-- component views

import Components.Main.View.BufferSnapshot as BufferSnapshot
import Components.Main.View.KnobsAndSliders as KnobsAndSliders

view : Model -> Html Msg
view model =
    div [ class "main-footer" ]
        [ p []
            [ text (Maybe.withDefault "" model.compilationError) ]
          -- , Html.map VolumeSliderMsg (Slider.view model.mainVolume)
          -- , p []
          --   [ text "Audio Meter Value: "
          --   , text (toString model.audioMeter)
          --   ]
          -- , Html.map AudioMeterMsg (AudioMeter.view model.audioMeter)
          -- , FFTBarGraph.view model.fftData
        , KnobsAndSliders.view model
        , pianoView model
        , maybeView BufferSnapshot.view model.bufferSnapshot
        , maybeView
            (\svgString -> (div [ property "innerHTML" <| Json.Encode.string svgString ] [] ))
            model.faustSvg
        ]


pianoView : Model -> Html Msg
pianoView model =
    if FaustControls.showPiano model.uiInputs then
        Piano.view { blackKey = Color.black, whiteKey = Color.white } 6 12 PianoKeyMouseDown
    else
        div [] []
