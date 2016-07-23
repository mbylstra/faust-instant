module Main.Commands exposing (..)

--------------------------------------------------------------------------------
import Task

import FirebaseAuth

import Main.Types exposing (..)
import Main.Ports exposing (compileFaustCode)
import Main.Constants

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



fetchCurrentFirebaseUser : Cmd Msg
fetchCurrentFirebaseUser =
  let
    task = FirebaseAuth.getCurrentUser Main.Constants.firebaseConfig
  in
    Task.perform (\_ -> GeneralError) CurrentFirebaseUserFetched task


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
