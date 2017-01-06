module Components.Main.Subscriptions exposing (subscriptions)

--------------------------------------------------------------------------------

import Components.HotKeys as HotKeys
import Components.Main.Types exposing (..)
-- import Components.Arpeggiator as Arpeggiator
import Components.Main.Ports exposing (..)


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


subscriptions : Model -> List (Sub Msg)
subscriptions model =
    [ incomingFaustCode FaustCodeChanged
    , incomingCompilationErrors CompilationError
      --, Sub.map AudioMeterMsg (incomingAudioMeterValue AudioMeter.Updated)
    , Sub.map HotKeysMsg HotKeys.subscription
      -- , incomingFFTData NewFFTData
    , incomingDSPCompiled DSPCompiled
    , incomingTextMeasurements NewTextMeasurement
    , incomingWebfontsActive (\_ -> WebfontsActive)
    , rawMidiInputEvents RawMidiInputEvent
    , incomingBufferSnapshot BufferSnapshot
    , incomingBarGraphUpdate BarGraphUpdate
    ]
    -- ++ ( if model.on then
    --         [ incomingAudioBufferClockTick AudioBufferClockTick ]
    --     else
    --         []
    --     )
        -- ++ (if model.arpeggiatorOn then
        --         [ Sub.map ArpeggiatorMsg (Arpeggiator.subscription model.arpeggiator) ]
        --     else
        --         []
        --    )
