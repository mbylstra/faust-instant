module Components.Midi exposing (MidiInputEvent(..), parseRawMidiEvent)


type MidiInputEvent
    = NoteOn ( Int, Float )
    | NoteOff Int
    | MidiEventNotImplemented



-- update : Model MidiInputEvent -> Model


parseRawMidiEvent : ( Int, Int, Int ) -> MidiInputEvent
parseRawMidiEvent ( first, second, third ) =
    case first of
        144 ->
            let
                midiNote =
                    second

                velocity =
                    (toFloat third) / 128.0
            in
                NoteOn ( midiNote, velocity )

        128 ->
            let
                midiNote =
                    second
            in
                NoteOff midiNote

        _ ->
            MidiEventNotImplemented
