module Components.Main.View.MainFooter exposing (view)

-- core

import Color


-- html

import Html exposing (..)
import Html.Attributes exposing (..)

-- external components

import HtmlHelpers exposing (maybeView)

-- project components

import Components.Piano as Piano
import Components.FaustUiModel as FaustUiModel


-- import FaustProgram

import Components.Main.Types exposing (..)
import Components.Main.View.KnobsAndSliders as KnobsAndSliders


view : Model -> Html Msg
view model =
    div [ class "main-footer" ]
        [ maybeView (\error -> p [] [text error]) model.compilationError
        -- [ p []
        --     [ text (Maybe.withDefault "" model.compilationError) ]
          -- , Html.map VolumeSliderMsg (Slider.view model.mainVolume)
          -- , p []
          --   [ text "Audio Meter Value: "
          --   , text (toString model.audioMeter)
          --   ]
          -- , Html.map AudioMeterMsg (AudioMeter.view model.audioMeter)
          -- , FFTBarGraph.view model.fftData
        , KnobsAndSliders.view model
        , pianoView model
        ]


pianoView : Model -> Html Msg
pianoView model =
    if FaustUiModel.showPiano model.faustUiInputs then
        Piano.view { blackKey = Color.black, whiteKey = Color.white } 6 12 PianoKeyMouseDown
    else
        div [] []
