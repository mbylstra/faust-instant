module Components.StepSequencer exposing (..)

import Html exposing (div, button, text, node, h2, p)
import Html.Attributes exposing (style, class)
import Html
import GridControl
import Components.StepSequencer.Types exposing (Model)
import Matrix exposing (Matrix)


-- Model


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
            params.twoDimensional
    }


get2DValues : Model -> List (Maybe Int)
get2DValues model =
    let
        indexes =
            List.range 0 (GridControl.width model.gridControl)
    in
        List.map (GridControl.valueAtColumn model.gridControl) indexes


getMatrix : Model -> Matrix Bool
getMatrix model =
    GridControl.getMatrix model.gridControl



-- Update


update : GridControl.Msg -> Model -> ( Model, List GridControl.OutMsg )
update gridControlMsg model =
    let
        ( gridControl, outMsgs ) =
            GridControl.update gridControlMsg model.gridControl
    in
        ( { model | gridControl = gridControl }, outMsgs )



-- View


view : String -> Model -> Html.Html GridControl.Msg
view className model =
    div [ class className ]
        [ GridControl.view { columnGroupLength = 2 } model.gridControl ]
