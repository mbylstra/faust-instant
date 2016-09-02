port module Main.Ports exposing (..)

--------------------------------------------------------------------------------

import Json.Decode
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

port compileFaustCode
  : { faustCode: String, polyphonic: Bool, numVoices: Int, bufferSize: Int }
  -> Cmd msg

port setControlValue
  : (String, Float) -> Cmd msg

port setPitch
  : Float -> Cmd msg

port incomingCompilationErrors
  : (Maybe String -> msg) -> Sub msg

port incomingFaustCode
  : (String -> msg) -> Sub msg

port updateFaustCode
  : String -> Cmd msg

port layoutUpdated
  : () -> Cmd msg

port updateMainVolume
  : Float -> Cmd msg

port incomingAudioMeterValue
  : (Float -> msg) -> Sub msg

port incomingFFTData
  : (List Float -> msg) -> Sub msg

port incomingDSPCompiled
  : (List Json.Decode.Value -> msg) -> Sub msg

port elmAppInitialRender
  : () -> Cmd msg

port measureText
  :  String -> Cmd msg

port incomingTextMeasurements
  : (Int -> msg) -> Sub msg
