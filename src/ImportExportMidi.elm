module ImportExportMidi exposing (..)

import BinaryBase64
import CoMidi
import CoMidiConverter
import MidiFileGenerator.Types exposing (..)
import MidiFileGenerator exposing (generateMidiFileData)


midiToBase64 : MidiRecording -> String
midiToBase64 midiRecording =
    midiRecording
        |> generateMidiFileData
        |> BinaryBase64.encode



-- import from midi file


importFromBinaryString : String -> Result String MidiRecording
importFromBinaryString binaryString =
    binaryString
        |> CoMidi.normalise
        |> CoMidi.parse
        |> Result.map CoMidiConverter.convertFrom


isNoteOn : MidiMessage -> Bool
isNoteOn ( ticks, midiEvent ) =
    case midiEvent of
        NoteOn _ ->
            True

        _ ->
            False
