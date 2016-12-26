module Components.Main.Types exposing (..)

--------------------------------------------------------------------------------
-- core

import Json.Decode
import Dict exposing (Dict)
import Http

-- external components

import FirebaseAuth exposing (AuthProvider(..), SignInWithPopupError(..))
import Material
import Material.Menu
import SignupView
import GridControl


-- project components

import Components.HotKeys as HotKeys
import Components.Slider as Slider
-- import Components.Arpeggiator as Arpeggiator
import Components.FaustProgram as FaustProgram
import Components.User as User
import Components.SimpleDialog as SimpleDialog
import Components.UserSettingsForm as UserSettingsForm
import Components.Midi as Midi
import Components.FaustUiModel exposing (FaustUi, InputRecord)
import Components.StepSequencer.Types as StepSequencerTypes


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


type alias Flags =
    { title : String
    , code : String
    }

type alias SongPosition =
    { bar : Int
    , beat : Int
    , tick : Int
    }

type alias Model =
    { on : Bool
    , faustProgram : FaustProgram.Model
    , isDemoProgram : Bool
    , online :
        Bool
        -- Do we have internet?
    , compilationError : Maybe String
    , hotKeys : HotKeys.Model
    , mainVolume : Slider.Model
    , fftData : List Float
    , faustUi : Maybe FaustUi
    , faustUiInputs : Dict String (Float, InputRecord)
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
    , audioClockTime : Float
    , tempo : Float
    , lastMetronomeTickTime : Float
    , globalSongPosition : SongPosition
    , numberOfBeatsPerBar : Int
    , stepSequencer : StepSequencerTypes.Model
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
    | DSPCompiled Json.Decode.Value
    | SliderChanged String Float
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
    | GridControlMsg GridControl.Msg
    | AudioBufferClockTick Float
    | MetronomeTick -- the metronome ticks 24 times per beat
    | SetPitch Float
    | ToggleOnOff


type Polyphony
    = Monophonic
    | Polyphonic Int
