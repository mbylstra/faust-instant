module Main.Types exposing (..)

--------------------------------------------------------------------------------

-- core
import Json.Decode
import Array exposing (Array)

-- external components
import FirebaseAuth exposing (AuthProvider(..), SignInWithPopupError(..))
import Material
import Material.Menu
import HttpBuilder

-- project components
import HotKeys
import Slider
import Arpeggiator
import SignupView
import FaustControls
import FaustProgram
import User
import SimpleDialog
import UserSettingsForm

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

type alias Model =
  { faustProgram : FaustProgram.Model
  , online : Bool -- Do we have internet?
  , compilationError : Maybe String
  , hotKeys : HotKeys.Model
  , mainVolume : Slider.Model
  , fftData : List Float
  , uiInputs : UiInputs
  , polyphony : Polyphony
  , bufferSize : Int
  , loading : Bool
  , arpeggiator : Arpeggiator.Model
  , arpeggiatorOn : Bool
  , signupView : SignupView.Model
  , user : Maybe User.Model
  , authToken : Maybe String
  -- , userMenu : Material.Menu.Model
  , mdl : Material.Model
  , userSettingsDialog : SimpleDialog.Model
  , userSettingsForm : Maybe UserSettingsForm.Model
  , staffPicks : List FaustProgram.Model
  , myPrograms : List FaustProgram.Model
  , textMeasurementWidth : Maybe Int
  }

type Msg
  = NoOp
  | HttpBuilderError (HttpBuilder.Error String)
  | Compile
  | CompilationError (Maybe String)
  | FaustCodeChanged String
  | HotKeysMsg HotKeys.Msg
  | VolumeSliderMsg Slider.Msg
  | NewFFTData (List Float)
  | DSPCompiled (List Json.Decode.Value)
  | SliderChanged Int Float
  | PianoKeyMouseDown Float
  | BufferSizeChanged Int
  | ArpeggiatorMsg Arpeggiator.Msg
  | SignupViewMsg SignupView.Msg
  | Error SignInWithPopupError

  | FirebaseLoginSuccess FirebaseAuth.User
  | CurrentFirebaseUserFetched (Maybe FirebaseAuth.User)

  | SuccessfulPut
  | GeneralError -- beacuse I'm lazy
  | Save
  | Fork
  | FaustProgramPosted String
  | LogOutClicked
  | UserSignedOut
  | UserSettingsDialogMsg SimpleDialog.Msg
  | OpenUserSettingsDialog
  | UserSettingsFormMsg UserSettingsForm.Msg
  | FetchedStaffPicks (List (String, FaustProgram.Model))
  | FetchedUserPrograms (List (String, FaustProgram.Model))
  | OpenProgram FaustProgram.Model
  | TitleUpdated String
  | NewTextMeasurement Int
  | WebfontsActive

  -- Material Design Lite
  | MDL Material.Msg
  | MenuMsg Int Material.Menu.Msg

type Polyphony
  = Monophonic
  | Polyphonic Int

type alias UiInputs = Array (FaustControls.SliderData)
