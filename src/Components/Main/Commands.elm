module Components.Main.Commands exposing (..)

--------------------------------------------------------------------------------

import Task
import FirebaseAuth
import Components.Main.Types exposing (..)
import Components.Main.Ports exposing (compileFaustCode, saveToLocalStoragePort)
import Components.Main.Constants as Constants
import Components.Main.Http.Firebase
    exposing
        ( getUserFaustPrograms
        , getFaustProgram
        )
import Components.User as User


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- attempt : (Result x a -> msg) -> Task x a -> Cmd msg

generalErrorTagger : (data -> Msg) -> (Result x data -> Msg)
generalErrorTagger msgTagger result =
    case result of
      Err _ ->
          GeneralError
      Ok data ->
          msgTagger data


fetchCurrentFirebaseUser : Cmd Msg
fetchCurrentFirebaseUser =
    let
        task =
            FirebaseAuth.getCurrentUser Constants.firebaseConfig
        tagger = generalErrorTagger CurrentFirebaseUserFetched

    in
        Task.attempt tagger task


signOutFirebaseUser : Cmd Msg
signOutFirebaseUser =
    let
        task =
            FirebaseAuth.signOut Constants.firebaseConfig
        tagger = generalErrorTagger (\_ -> UserSignedOut)
    in
        Task.attempt tagger task


createCompileCommand : Model -> Cmd Msg
createCompileCommand model =
    case model.polyphony of
        Polyphonic numVoices ->
            compileFaustCode
                { faustCode = model.faustProgram.code
                , polyphonic = True
                , numVoices = numVoices
                , bufferSize = model.bufferSize
                }

        Monophonic ->
            compileFaustCode
                { faustCode = model.faustProgram.code
                , polyphonic = False
                , numVoices = 1
                , bufferSize = model.bufferSize
                }


-- fetchUserPrograms : User.Model -> Cmd Msg
-- fetchUserPrograms user =
--     Task.perform HttpBuilderError FetchedUserPrograms (getUserFaustPrograms user)


-- fetchStaffPicks : Cmd Msg
-- fetchStaffPicks =
--     Task.perform HttpBuilderError FetchedStaffPicks Components.Main.Http.Firebase.getStaffPicks


-- fetchTheDemoProgram : Cmd Msg
-- fetchTheDemoProgram =
--     Task.perform HttpError FetchedTheDemoProgram (getFaustProgram Constants.theDemoProgramKey)


saveToLocalStorage : Model -> Cmd Msg
saveToLocalStorage model =
    let
        data =
            { title = model.faustProgram.title, code = model.faustProgram.code }
    in
        saveToLocalStoragePort data
