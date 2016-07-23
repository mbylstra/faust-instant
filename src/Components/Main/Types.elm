module Main.Types exposing (..)

--------------------------------------------------------------------------------

import Json.Decode
import Array exposing (Array)

import FirebaseAuth exposing (AuthProvider(..), SignInWithPopupError(..))
import LocalStorage
import HttpBuilder

import HotKeys
import Examples
import Slider
import Arpeggiator
import SignupView
import FaustControls
import FaustProgram
import User

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
  }

type Msg
  = Compile
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
  | Success FirebaseAuth.User
  | SuccessfulPut (Maybe String)
  | GeneralError -- beacuse I'm lazy
  | Save
  | FaustProgramPosted (HttpBuilder.Response String)
  | AuthTokenRetrievedFromLocalStorage String
  | AuthTokenNotRetrievedFromLocalStorage LocalStorage.Error

type Polyphony
  = Monophonic
  | Polyphonic Int

type alias UiInputs = Array (FaustControls.SliderData)
