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
import Components.StepSequencer as StepSequencer


-- import FaustProgram

import Components.Main.Types exposing (..)
import Components.Main.View.KnobsAndSliders as KnobsAndSliders
import Icons.Drum
import Icons.Snare
import Icons.HiHat
import Components.FaustCodeWrangler exposing (wrangleFaustCodeForFaustInstantGimmicks)


view : Model -> Html Msg
view model =
    div [ class "main-footer" ]
        ([ maybeView (\error -> p [] [ text error ]) model.compilationError
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
        showPiano =
            (FaustUiModel.showPiano model.faustUiInputs)
                || (String.contains "_FI_freq;" (wrangleFaustCodeForFaustInstantGimmicks model.faustProgram.code))

        -- needs a big refactor!
        notePitchStepSequencer =
            if showPiano then
                [ Html.map NotePitchStepSequencerMsg <|
                    StepSequencer.view
                        "step-sequencer pitch-step-sequencer"
                        model.notePitchStepSequencer
                ]
            else
                []
    in
        div [ class "step-sequencers" ]
            (notePitchStepSequencer ++ [ drumStepSequencerView model ])



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
    div [ class "drum-step-sequencer-wrapper" ]
        [ div [ class "drum-step-sequencer-icons" ]
            [ Icons.HiHat.icon, Icons.Snare.icon, Icons.Drum.icon ]
        , Html.map DrumStepSequencerMsg <|
            StepSequencer.view "step-sequencer drum-step-sequencer" model.drumStepSequencer
        ]
