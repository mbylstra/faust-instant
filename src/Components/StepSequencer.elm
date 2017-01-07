module Components.StepSequencer exposing (..)

import Html exposing (div, button, text, node, h2, p)
import Html.Attributes exposing (style, class)
import Html
import GridControl


-- import Components.Main.Types as MainTypes

import Components.StepSequencer.Types exposing (Model)


type alias Params =
    { numBars : Int
    , numKeys : Int
    , notesPerBar : Int
    , twoDimensional : Bool
    }


init : Params -> Model
init params =
    { position = 0
    , gridControl =
        GridControl.init
            (params.notesPerBar * params.numBars)
            params.numKeys
            False
    }



-- no change required


update : GridControl.Msg -> Model -> ( Model, List GridControl.OutMsg )
update gridControlMsg model =
    let
        ( gridControl, outMsgs ) =
            GridControl.update gridControlMsg model.gridControl
    in
        ( { model | gridControl = gridControl }, outMsgs )



-- TODO: the mapping needs to happen one level up!


view : String -> Model -> Html.Html GridControl.Msg
view className model =
    div [ class className ]
        [ GridControl.view { columnGroupLength = 2 } model.gridControl ]
