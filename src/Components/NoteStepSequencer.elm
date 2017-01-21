module Components.NoteStepSequencer exposing (..)

import Components.Main.Types exposing (Model, Msg(NotePitchStepSequencerMsg))
import Components.StepSequencer as StepSequencer
import Html exposing (..)
import Components.Main.Ports exposing (setControlValue)
import GridControl
import Html
import Json.Encode exposing (..)


-- Update


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


handleMsg : GridControl.Msg -> Model -> ( Model, Cmd Msg )
handleMsg gridControlMsg model =
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
getSetValueCmds : Model -> List (Cmd Msg)
getSetValueCmds model =
    StepSequencer.get2DValues model.notePitchStepSequencer
        |> List.map (Maybe.withDefault 0)
        |> List.indexedMap noteCoordToCmds
        |> List.concat



-- view


view : Model -> Html.Html Msg
view model =
    Html.map NotePitchStepSequencerMsg <|
        StepSequencer.view
            "step-sequencer pitch-step-sequencer"
            model.notePitchStepSequencer
