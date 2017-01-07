module Components.FaustCodeWrangler exposing (..)

import Array
import List.Extra
import Regex


wrangleFaustCodeForFaustInstantGimmicks : String -> String
wrangleFaustCodeForFaustInstantGimmicks faustCode =
    faustCode
        |> insertBpmSlider
        |> insertDrumBuddy
        |> replaceFreqAndGateInputsWithStepSequencer


insertBpmSlider : String -> String
insertBpmSlider faustCode =
    """_FI_bpm = hslider("BPM", 120.0, 40.0, 300.0, 0.1);
    """ ++ faustCode


insertDrumBuddy : String -> String
insertDrumBuddy faustCode =
    let
        drumBuddyImport =
            """
            _FI_drumBuddy = library("http://lib.faustinstant.net/mbylstra/fi-drum-buddy.lib").drumBuddy;
        """

        getIndexOfLastLineWithSemiColon : String -> Int
        getIndexOfLastLineWithSemiColon code =
            String.lines code
                |> List.indexedMap (\i line -> ( i, line ))
                |> List.foldl
                    (\( i, line ) acc ->
                        if String.contains ";" line then
                            i
                        else
                            acc
                    )
                    -1

        appendDrumBuddy : Int -> String -> String
        appendDrumBuddy lineNumber code =
            if lineNumber >= 0 then
                let
                    linesArray =
                        String.lines code |> Array.fromList

                    maybeLine : Maybe String
                    maybeLine =
                        Array.get lineNumber linesArray

                    updateLine line =
                        let
                            lastSemicolonIndex =
                                String.indexes ";" line
                                    |> List.Extra.last
                                    |> Maybe.withDefault 0

                            lineNoSemicolon =
                                String.slice 0 lastSemicolonIndex line
                        in
                            lineNoSemicolon ++ " + _FI_drumBuddy(_FI_bpm);"

                    maybeNewCode =
                        Maybe.map
                            (\line ->
                                Array.set lineNumber (updateLine line) linesArray
                                    |> Array.toList
                                    |> String.join "\n"
                            )
                            maybeLine
                in
                    maybeNewCode
                        |> Maybe.withDefault code
            else
                -- this won't work, so don't alter the code
                code

        drumBuddyAppended =
            appendDrumBuddy (getIndexOfLastLineWithSemiColon faustCode) faustCode
    in
        drumBuddyImport ++ drumBuddyAppended


replaceFreqAndGateInputsWithStepSequencer : String -> String
replaceFreqAndGateInputsWithStepSequencer faustCode =
    let
        freqInputRegex =
            Regex.regex "(nentry|vslider|hslider)\\(\"freq.*"

        gateInputRegex =
            Regex.regex "button\\(\"gate.*"

        importStatement =
            """
            _FI_pitchStepSequencer = library("http://lib.faustinstant.net/mbylstra/fi-gated-pitch-step-sequencer.lib").pitchStepSequencer;
            _FI_freq = _FI_pitchStepSequencer(_FI_bpm) : _, !;
            _FI_gate = _FI_pitchStepSequencer(_FI_bpm) : !, _;
        """
    in
        importStatement
            ++ (faustCode
                    |> Regex.replace Regex.All freqInputRegex (\_ -> "_FI_freq;")
                    |> Regex.replace Regex.All gateInputRegex (\_ -> "_FI_gate;")
               )



-- replaceGateInputWithStepSequencer : String -> String
-- replaceGateInputWithStepSequencer faustCode =
--     let
--         importStatement = """
--             pitchStepSequencer = library("http://lib.faustinstant.net/mbylstra/fi-pitch-step-sequencer.lib").pitchStepSequencer;
--         """
--     in
--         importStatement
--             ++ (Regex.replace Regex.All freqInputRegex (\_ -> "pitchStepSequencer(bpm);") faustCode)
