module Components.Main.Update.StepSequencers exposing (..)

--------------------------------------------------------------------------------

import GridControl
import Components.Main.Types exposing (..)
import Components.Main.Ports as Ports
    exposing
        ( updateFaustCode
        , updateMainVolume
        , layoutUpdated
        , setControlValue
        , measureText
        )
import Components.StepSequencer as StepSequencer
import Matrix
import Array


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


getAllSetValueCmds : Model -> List (Cmd Msg)
getAllSetValueCmds model =
    getAllDrumStepSequencerSetValueCmds model
        ++ (getAllNoteStepSequencerSetValueCmds model)
