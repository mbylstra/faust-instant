module Components.NoteStepSequencer exposing (..)

import Components.Main.Types exposing (Model, Msg(NotePitchStepSequencerMsg))
import Components.StepSequencer as StepSequencer
import Html exposing (..)
import Components.Main.Ports exposing (setControlValue)
import GridControl
import Html
import MidiFileGenerator.Types exposing (..)
import ImportExportMidi exposing (isNoteOn, midiToBase64, importFromBinaryString)


-- Update


yToPitch : Int -> Int
yToPitch y =
    60 + (12 - y)


noteCoordToCmds : Int -> Int -> List (Cmd Msg)
noteCoordToCmds x y =
    let
        notePitchAddress =
            "/0x00/_FI_notestepsequencer_" ++ toString x

        noteGateAddress =
            "/0x00/_FI_gatestepsequencer_9999-" ++ toString x
    in
        [ setControlValue ( notePitchAddress, yToPitch y |> toFloat )
        , setControlValue ( noteGateAddress, 1.0 )
        ]


toNotesList : Model -> List Int
toNotesList model =
    StepSequencer.get2DValues model.notePitchStepSequencer
        |> List.map (Maybe.withDefault 0)
        |> List.map yToPitch


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


setNotes : List Int -> Model -> Model
setNotes notes model =
    let
        newStepSequencer =
            StepSequencer.set1DValues notes model.notePitchStepSequencer
    in
        { model | notePitchStepSequencer = newStepSequencer }



-- view


view : Model -> Html.Html Msg
view model =
    Html.map NotePitchStepSequencerMsg <|
        StepSequencer.view
            "step-sequencer pitch-step-sequencer"
            model.notePitchStepSequencer



-- export to midi file


convertToMidiRecording : Model -> MidiRecording
convertToMidiRecording model =
    let
        notes : List Int
        notes =
            toNotesList model

        noteDuration =
            1

        toNoteOnOffPair note =
            [ ( 0, NoteOn { channel = 0, key = note, velocity = 100 } )
            , ( 1, NoteOff { channel = 0, key = note, velocity = 0 } )
            ]
    in
        ( { formatType = 1
          , trackCount = 1
          , ticksPerBeat = 2
          }
        , [ List.concatMap toNoteOnOffPair notes ]
        )


getNoteOnKey : MidiMessage -> Maybe Int
getNoteOnKey midiMessage =
    case midiMessage of
        ( _, NoteOn { channel, key, velocity } ) ->
            Just key

        _ ->
            Nothing



-- import from midi file


updateModelFromMidiRecording : MidiRecording -> Model -> Result String Model
updateModelFromMidiRecording ( header, tracks ) model =
    case List.head tracks of
        Just midiMessages ->
            let
                notes : List Int
                notes =
                    midiMessages
                        |> List.filter isNoteOn
                        |> List.filterMap getNoteOnKey
            in
                Ok (setNotes notes model)

        Nothing ->
            Err "Midi data has empty track list"
