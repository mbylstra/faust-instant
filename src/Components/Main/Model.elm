module Main.Model exposing (..)

--------------------------------------------------------------------------------

-- core
import Array exposing (Array)
-- import Task

-- external components
import SignupView
-- import LocalStorage
-- import FirebaseAuth

-- project components
import FaustProgram
import HotKeys
import Slider
import Arpeggiator
import Examples

-- component modules
import Main.Types exposing (..)
import Main.Ports exposing (..)
import Main.Constants
import Main.Commands exposing (fetchCurrentFirebaseUser)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


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
    , bufferSize = Main.Constants.defaultBufferSize
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
    , fetchCurrentFirebaseUser
    -- , Task.perform AuthTokenNotRetrievedFromLocalStorage AuthTokenRetrievedFromLocalStorage
    --     (LocalStorage.get "authToken")
    ]
