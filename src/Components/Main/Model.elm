module Main.Model exposing (..)

--------------------------------------------------------------------------------

-- core
import Array exposing (Array)
import Task


-- external components
import SignupView
-- import LocalStorage
-- import FirebaseAuth
import Material

-- project components
import FaustProgram
import HotKeys
import Slider
import Arpeggiator
import SimpleDialog
import User
import Main.Http.Firebase

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
    -- , user = Just User.dummyModel
    , authToken = Nothing
    -- , authToken = Just "asdf"
    , mdl = Material.model
    , userSettingsDialog = SimpleDialog.init
    , userSettingsForm = Nothing
    , staffPicks = []
    , myPrograms = []
    }
    !
    [ Cmd.map HotKeysMsg hotKeysCommand
    , elmAppInitialRender ()
    , fetchCurrentFirebaseUser
    , Task.perform HttpBuilderError FetchedStaffPicks Main.Http.Firebase.getStaffPicks
    ]

updateUser : Maybe User.Model -> Model -> Model
updateUser maybeUser model =
  let
    faustProgram = model.faustProgram
  in
    case maybeUser of
      Just user ->
        { model
        | user = Just user
        , faustProgram = { faustProgram | authorUid = Just user.uid }
        }
      Nothing ->
        { model
        | user = Nothing,
          faustProgram = { faustProgram | authorUid = Nothing }
        }

isLoggedIn : Model -> Bool
isLoggedIn model =
  case model.user of
    Just _ -> True
    Nothing -> False
