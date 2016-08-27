module Main.Types exposing (..)

--------------------------------------------------------------------------------

-- core
import Json.Decode
import Array exposing (Array)

-- external libs
import HttpBuilder

-- external components
import FirebaseAuth exposing (AuthProvider(..), SignInWithPopupError(..))
import Material
import Material.Menu

-- project components
import HotKeys
import Examples
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
  , compilationError : Maybe String
  , hotKeys : HotKeys.Model
  , examples : List (String, String)
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
  }

type Msg
  = NoOp
  | Compile
  | CompilationError (Maybe String)
  | FaustCodeChanged String
  | HotKeysMsg HotKeys.Msg
  | ExamplesMsg Examples.Msg
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
  | SuccessfulPut
  | GeneralError -- beacuse I'm lazy
  | Save
  | FaustProgramPosted String
  | CurrentFirebaseUserFetched (Maybe FirebaseAuth.User)
  | LogOutClicked
  | UserSignedOut
  | UserSettingsDialogMsg SimpleDialog.Msg
  | OpenUserSettingsDialog
  | UserSettingsFormMsg UserSettingsForm.Msg

  -- Material Design Lite
  | MDL Material.Msg
  | MenuMsg Int Material.Menu.Msg

type Polyphony
  = Monophonic
  | Polyphonic Int

type alias UiInputs = Array (FaustControls.SliderData)
