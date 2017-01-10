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
import Matrix
import Array


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


yToPitch : Int -> Float
yToPitch y =
    toFloat <| 60 + (12 - y)


noteCoordToCmds : Int -> Int -> List (Cmd Msg)
noteCoordToCmds x y =
    let
        notePitchAddress =
            "/0x00/_FI_notestepsequencer_" ++ toString x

        noteGateAddress =
            "/0x00/_FI_gatestepsequencer_9999-" ++ toString x
    in
        [ setControlValue ( notePitchAddress, yToPitch y )
        , setControlValue ( noteGateAddress, 1.0 )
        ]


handleNotePitchStepSequencerMsg : GridControl.Msg -> Model -> ( Model, Cmd Msg )
handleNotePitchStepSequencerMsg gridControlMsg model =
    let
        ( stepSequencer, outMsgs ) =
            StepSequencer.update gridControlMsg model.notePitchStepSequencer

        outMsgToCmds outMsg =
            case outMsg of
                GridControl.CellUpdated { x, y, value } ->
                    noteCoordToCmds x y

        cmds =
            List.concatMap outMsgToCmds outMsgs

        _ =
            Debug.log "cmds" cmds
    in
        { model | notePitchStepSequencer = stepSequencer } ! cmds


{-| NOTE: this is potentially bad for performance as all Faust setValue msgs could be wrapped in
-- an array and sent as a single Msg
-}
getAllNoteStepSequencerSetValueCmds : Model -> List (Cmd Msg)
getAllNoteStepSequencerSetValueCmds model =
    StepSequencer.get2DValues model.notePitchStepSequencer
        |> List.map (Maybe.withDefault 0)
        |> List.indexedMap noteCoordToCmds
        |> List.concat


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


handleDrumStepSequencerMsg : GridControl.Msg -> Model -> ( Model, Cmd Msg )
handleDrumStepSequencerMsg gridControlMsg model =
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
getAllDrumStepSequencerSetValueCmds : Model -> List (Cmd Msg)
getAllDrumStepSequencerSetValueCmds model =
    StepSequencer.getMatrix model.drumStepSequencer
        |> Matrix.indexedMap drumCoordToMsg
        |> .data
        |> Array.toList


getAllSetValueCmds : Model -> List (Cmd Msg)
getAllSetValueCmds model =
    getAllDrumStepSequencerSetValueCmds model
        ++ (getAllNoteStepSequencerSetValueCmds model)
