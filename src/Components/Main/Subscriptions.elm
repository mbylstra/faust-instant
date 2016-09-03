module Main.Subscriptions exposing (subscriptions)

--------------------------------------------------------------------------------

import HotKeys

import Main.Types exposing (..)

import Arpeggiator

import Main.Ports exposing(..)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

subscriptions : Model -> List (Sub Msg)
subscriptions model =
    [ incomingFaustCode FaustCodeChanged
    , incomingCompilationErrors CompilationError
    --, Sub.map AudioMeterMsg (incomingAudioMeterValue AudioMeter.Updated)
    , Sub.map HotKeysMsg HotKeys.subscription
    , incomingFFTData NewFFTData
    , incomingDSPCompiled DSPCompiled
    , incomingTextMeasurements NewTextMeasurement
    , incomingWebfontsActive (\_ -> WebfontsActive)
    ]
    ++ (
      if model.arpeggiatorOn
      then [Sub.map ArpeggiatorMsg (Arpeggiator.subscription model.arpeggiator)]
      else []
    )
