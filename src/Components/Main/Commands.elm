module Main.Commands exposing (..)

--------------------------------------------------------------------------------
import Task

import FirebaseAuth

import Main.Types exposing (..)
import Main.Ports exposing (compileFaustCode)
import Main.Constants
import Main.Http.Firebase exposing (getUserFaustPrograms)

import User

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



fetchCurrentFirebaseUser : Cmd Msg
fetchCurrentFirebaseUser =
  let
    task = FirebaseAuth.getCurrentUser Main.Constants.firebaseConfig
  in
    Task.perform (\_ -> GeneralError) CurrentFirebaseUserFetched task

signOutFirebaseUser : Cmd Msg
signOutFirebaseUser =
  let
    task = FirebaseAuth.signOut Main.Constants.firebaseConfig
  in
    Task.perform (\_ -> GeneralError) (\_ -> UserSignedOut) task


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

fetchUserPrograms : User.Model -> Cmd Msg
fetchUserPrograms user =
  Task.perform HttpBuilderError FetchedUserPrograms (getUserFaustPrograms user)
