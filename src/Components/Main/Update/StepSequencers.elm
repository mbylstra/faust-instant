module Components.Main.Update.StepSequencers exposing (..)

--------------------------------------------------------------------------------

import GridControl
import Components.Main.Types exposing (..)
import Components.Main.Ports as Ports
    exposing
        ( updateFaustCode
        , updateMainVolume
        , layoutUpdated
        , setControlValue
        , measureText
        )
import Components.StepSequencer as StepSequencer


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


handleNotePitchStepSequencerMsg : GridControl.Msg -> Model -> ( Model, Cmd Msg )
handleNotePitchStepSequencerMsg gridControlMsg model =
    let
        ( stepSequencer, outMsgs ) =
            StepSequencer.update gridControlMsg model.notePitchStepSequencer

        outMsgToCmds outMsg =
            case outMsg of
                GridControl.CellUpdated { x, y, value } ->
                    let
                        notePitchIndexAddress =
                            "/0x00/_FI_pitchstepsequencer-index"

                        notePitchValueAddress =
                            "/0x00/_FI_pitchstepsequencer-value"

                        yToPitch =
                            60 + (12 - y)

                        noteGateIndexAddress =
                            "/0x00/_FI_drumsequencer-index-9999"

                        noteGateValueAddress =
                            "/0x00/_FI_drumsequencer-value-9999"

                        gateValue =
                            case value of
                                True ->
                                    1.0

                                False ->
                                    0.0
                    in
                        [ setControlValue ( notePitchIndexAddress, toFloat (x) )
                        , setControlValue ( notePitchValueAddress, toFloat yToPitch )
                        , setControlValue ( noteGateIndexAddress, toFloat (x) )
                        , setControlValue ( noteGateValueAddress, gateValue )
                        ]

        cmds =
            List.concatMap outMsgToCmds outMsgs

        _ =
            Debug.log "cmds" cmds
    in
        { model | notePitchStepSequencer = stepSequencer } ! cmds


handleDrumStepSequencerMsg : GridControl.Msg -> Model -> ( Model, Cmd Msg )
handleDrumStepSequencerMsg gridControlMsg model =
    let
        ( stepSequencer, outMsgs ) =
            StepSequencer.update gridControlMsg model.drumStepSequencer

        _ =
            Debug.log "outMsgs" outMsgs

        outMsgToCmds outMsg =
            case outMsg of
                GridControl.CellUpdated { x, y, value } ->
                    let
                        indexAddress =
                            "/0x00/_FI_drumsequencer-index-" ++ toString (y)

                        valueAddress =
                            "/0x00/_FI_drumsequencer-value-" ++ toString (y)

                        valueInt =
                            case value of
                                True ->
                                    1

                                False ->
                                    0
                    in
                        [ setControlValue ( indexAddress, toFloat (x) )
                        , setControlValue ( valueAddress, toFloat (valueInt) )
                        ]

        cmds =
            List.concatMap outMsgToCmds outMsgs

        _ =
            Debug.log "cmds" cmds
    in
        { model | drumStepSequencer = stepSequencer } ! cmds
