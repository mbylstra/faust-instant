module Main.Model exposing (..)

--------------------------------------------------------------------------------

-- core
import Array exposing (Array)
import Task

-- external components
import SignupView
import LocalStorage
import FirebaseAuth

-- project components
import FaustProgram
import HotKeys
import Slider
import Arpeggiator
import Examples

-- component modules
import Main.Types exposing (..)
import Main.Ports exposing (..)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Defaults

defaultBufferSize : Int
defaultBufferSize = 512

sampleRate : Float
sampleRate = 44100.0

firebaseConfig : FirebaseAuth.Config
firebaseConfig =
  { apiKey = "AIzaSyDZmUzh7NIrLj82ourEnI1E4fffa1Zk2EE"
  , authDomain = "faust-instant.firebaseapp.com"
  , databaseURL = "https://faust-instant.firebaseio.com"
  }

-- Init

init : (Model, Cmd Msg)
init =
  let
    (hotKeys, hotKeysCommand) = HotKeys.init
  in
    { faustProgram = FaustProgram.init
    , compilationError = Nothing
    , hotKeys = hotKeys
    -- , fileReader = FileReader.init
    , examples = Examples.init
    , mainVolume = Slider.init 1.0
    , fftData = []
    , uiInputs = Array.empty
    , polyphony = Monophonic
    , bufferSize = defaultBufferSize
    , loading = False
    , arpeggiator = Arpeggiator.init
    , arpeggiatorOn = False
    , signupView = SignupView.init
    , user = Nothing
    , authToken = Nothing
    }
    !
    [ Cmd.map HotKeysMsg hotKeysCommand
    , elmAppInitialRender ()
    , Task.perform AuthTokenNotRetrievedFromLocalStorage AuthTokenRetrievedFromLocalStorage
        (LocalStorage.get "authToken")
    ]
