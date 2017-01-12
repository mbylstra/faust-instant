module Components.DrumStepSequencer exposing (..)

import Components.Main.Types exposing (Model, Msg(DrumStepSequencerMsg))
import Components.StepSequencer as StepSequencer
import Html exposing (..)
import Html.Attributes exposing (..)
import Icons.HiHat
import Icons.Snare
import Icons.Drum
import Components.Main.Ports exposing (setControlValue)
import GridControl
import Html
import Matrix
import Array


drumCoordToMsg : Int -> Int -> Bool -> Cmd Msg
drumCoordToMsg x y value =
    let
        address =
            "/0x00/_FI_gatestepsequencer_" ++ toString y ++ "-" ++ toString x

        valueInt =
            case value of
                True ->
                    1

                False ->
                    0
    in
        setControlValue ( address, toFloat valueInt )


handleMsg : GridControl.Msg -> Model -> ( Model, Cmd Msg )
handleMsg gridControlMsg model =
    let
        ( stepSequencer, outMsgs ) =
            StepSequencer.update gridControlMsg model.drumStepSequencer

        outMsgToCmds outMsg =
            case outMsg of
                GridControl.CellUpdated { x, y, value } ->
                    [ drumCoordToMsg x y value ]

        cmds =
            List.concatMap outMsgToCmds outMsgs
    in
        { model | drumStepSequencer = stepSequencer } ! cmds


{-| NOTE: this is potentially bad for performance as all Faust setValue msgs could be wrapped in
-- an array and sent as a single Msg
-}
getSetValueCmds : Model -> List (Cmd Msg)
getSetValueCmds model =
    StepSequencer.getMatrix model.drumStepSequencer
        |> Matrix.indexedMap drumCoordToMsg
        |> .data
        |> Array.toList


view : Model -> Html Msg
view model =
    div [ class "drum-step-sequencer-wrapper" ]
        [ div [ class "drum-step-sequencer-icons" ]
            [ Icons.HiHat.icon, Icons.Snare.icon, Icons.Drum.icon ]
        , Html.map DrumStepSequencerMsg <|
            StepSequencer.view "step-sequencer drum-step-sequencer" model.drumStepSequencer
        ]
