module Components.Main.Commands exposing (..)

--------------------------------------------------------------------------------
import Task
import FirebaseAuth
import Components.Main.Types exposing (..)
import Components.Main.Ports exposing (compileFaustCode, saveToLocalStoragePort)
import Components.Main.Constants as Constants
import Components.Main.Http.OnlineCompiler exposing (getSvgUrl)
import Components.FaustCodeWrangler exposing (wrangleFaustCodeForFaustInstantGimmicks)


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


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

    let
        wrangledFaustCode = wrangleFaustCodeForFaustInstantGimmicks model.faustProgram.code
    in
        case model.polyphony of
            Polyphonic numVoices ->
                compileFaustCode
                    { faustCode = wrangledFaustCode
                    , polyphonic = True
                    , numVoices = numVoices
                    , bufferSize = model.bufferSize
                    }

            Monophonic ->
                compileFaustCode
                    { faustCode = wrangledFaustCode
                    , polyphonic = False
                    , numVoices = 1
                    , bufferSize = model.bufferSize
                    }


createCompileCommands : Model -> List (Cmd Msg)
createCompileCommands model =
    [ createCompileCommand model
    , getSvgUrl SvgUrlFetched model.faustProgram.code
    ]


saveToLocalStorage : Model -> Cmd Msg
saveToLocalStorage model =
    let
        data =
            { title = model.faustProgram.title, code = model.faustProgram.code }
    in
        saveToLocalStoragePort data
