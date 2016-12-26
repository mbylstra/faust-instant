module Components.StepSequencer.Types exposing (..)

import GridControl

type alias Model =
    { position : Int
    , gridControl : GridControl.Model
    }
