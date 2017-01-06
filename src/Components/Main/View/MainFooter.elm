module Components.Main.View.MainFooter exposing (view)

-- core

-- import Color


-- html

import Html exposing (..)
import Html.Attributes exposing (..)

-- external components

import HtmlHelpers exposing (maybeView)

-- project components

-- import Components.Piano as Piano
import Components.FaustUiModel as FaustUiModel
import Components.PitchStepSequencer as PitchStepSequencer
import Components.DrumStepSequencer as DrumStepSequencer


-- import FaustProgram

import Components.Main.Types exposing (..)
import Components.Main.View.KnobsAndSliders as KnobsAndSliders

import Icons.Drum
import Icons.Snare
import Icons.HiHat


view : Model -> Html Msg
view model =
    div [ class "main-footer" ]
        (
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
            , stepSequencersView model
            ]
            -- ++ (pianoView model)
        )

stepSequencersView : Model -> Html Msg
stepSequencersView model =
    let
        pitchStepSequencer =
            if FaustUiModel.showPiano model.faustUiInputs then
                [ PitchStepSequencer.view "step-sequencer pitch-step-sequencer" model.pitchStepSequencer ]
            else
                []

    in
        div [ class "step-sequencers" ]
            ( pitchStepSequencer ++ [ drumStepSequencerView model ])

-- pianoView : Model -> List (Html Msg)
-- pianoView model =
--     if FaustUiModel.showPiano model.faustUiInputs then
--         [ StepSequencer.view model.stepSequencer
--         , Piano.view { blackKey = Color.black, whiteKey = Color.white } 6 12 PianoKeyMouseDown
--         ]
--     else
--         []

drumStepSequencerView : Model -> Html Msg
drumStepSequencerView model =
    div [ class "drum-step-sequencer-wrapper"]
        [ div [ class "drum-step-sequencer-icons" ]
            [ Icons.HiHat.icon, Icons.Snare.icon, Icons.Drum.icon ]
        , DrumStepSequencer.view "step-sequencer drum-step-sequencer" model.drumStepSequencer
        ]
