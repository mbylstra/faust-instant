module Components.Main.Types exposing (..)

--------------------------------------------------------------------------------
-- core

import Json.Decode
import Array exposing (Array)
import Http

-- external components

import FirebaseAuth exposing (AuthProvider(..), SignInWithPopupError(..))
import Material
import Material.Menu
import SignupView


-- project components

import Components.HotKeys as HotKeys
import Components.Slider as Slider
-- import Components.Arpeggiator as Arpeggiator
import Components.FaustControls as FaustControls
import Components.FaustProgram as FaustProgram
import Components.User as User
import Components.SimpleDialog as SimpleDialog
import Components.UserSettingsForm as UserSettingsForm
import Components.Midi as Midi


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


type alias Flags =
    { title : String
    , code : String
    }


type alias Model =
    { faustProgram : FaustProgram.Model
    , isDemoProgram : Bool
    , online :
        Bool
        -- Do we have internet?
    , compilationError : Maybe String
    , hotKeys : HotKeys.Model
    , mainVolume : Slider.Model
    , fftData : List Float
    , uiInputs : UiInputs
    , polyphony : Polyphony
    , bufferSize : Int
    , loading : Bool
    -- , arpeggiator : Arpeggiator.Model
    -- , arpeggiatorOn : Bool
    , signupView : SignupView.Model
    , user : Maybe User.Model
    , authToken :
        Maybe String
        -- , userMenu : Material.Menu.Model
    , mdl : Material.Model
    , userSettingsDialog : SimpleDialog.Model
    , userSettingsForm : Maybe UserSettingsForm.Model
    , staffPicks : List FaustProgram.Model
    , myPrograms : List FaustProgram.Model
    , textMeasurementWidth : Maybe Int
    , bufferSnapshot : Maybe (List Float)
    , faustSvgUrl : Maybe String
    }


type Msg
    = NoOp
    | HttpError Http.Error
    | Compile
    | CompilationError (Maybe String)
    | FaustCodeChanged String
    | HotKeysMsg HotKeys.Msg
    | VolumeSliderMsg Slider.Msg
      -- | NewFFTData (List Float)
    | DSPCompiled (List Json.Decode.Value)
    | SliderChanged Int Float
    | PianoKeyMouseDown Float
    | BufferSizeChanged Int
    -- | ArpeggiatorMsg Arpeggiator.Msg
    | SignupViewMsg SignupView.Msg
    | Error SignInWithPopupError
    | FirebaseLoginSuccess FirebaseAuth.User
    | CurrentFirebaseUserFetched (Maybe FirebaseAuth.User)
    | SuccessfulPut
    | GeneralError
      -- beacuse I'm lazy
    | Save
    | Fork
    | NewFile
    | DeleteCurrentFile
    | FaustProgramPosted String
    | LogOutClicked
    | UserSignedOut
    | UserSettingsDialogMsg SimpleDialog.Msg
    | OpenUserSettingsDialog
    | UserSettingsFormMsg UserSettingsForm.Msg
    | FetchedStaffPicks (List ( String, FaustProgram.Model ))
    | FetchedUserPrograms (List ( String, FaustProgram.Model ))
    | FetchedTheDemoProgram FaustProgram.Model
    | OpenProgram FaustProgram.Model
    | TitleUpdated String
    | NewTextMeasurement Int
    | WebfontsActive
    | BufferSnapshot (List Float)
    | SvgUrlFetched String
      -- Midi
    | RawMidiInputEvent ( Int, Int, Int )
    | MidiInputEvent Midi.MidiInputEvent
      -- Material Design Lite
    | MDL (Material.Msg Msg)
    | MenuMsg Int Material.Menu.Msg



type Polyphony
    = Monophonic
    | Polyphonic Int


type alias UiInputs =
    Array FaustControls.SliderData
