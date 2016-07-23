module Main.Commands exposing (..)

--------------------------------------------------------------------------------
import Main.Types exposing (..)
import Main.Ports exposing (compileFaustCode)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

createCompileCommand : Model -> Cmd Msg
createCompileCommand model =
  case model.polyphony of
    Polyphonic numVoices ->
      compileFaustCode
        { faustCode = model.faustProgram.code, polyphonic = True
        , numVoices = numVoices, bufferSize = model.bufferSize
        }
    Monophonic ->
      compileFaustCode
        { faustCode = model.faustProgram.code, polyphonic = False
        , numVoices = 1, bufferSize = model.bufferSize
        }
