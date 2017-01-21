module Components.StepSequencer exposing (..)

import Html exposing (div, button, text, node, h2, p)
import Html.Attributes exposing (style, class)
import Html
import GridControl
import Components.StepSequencer.Types exposing (Model)
import Matrix exposing (Matrix)
import Json.Encode as Encode
import Array exposing (Array)


-- Model


type alias Params =
    { numBars : Int
    , numKeys : Int
    , notesPerBar : Int
    , twoDimensional : Bool
    }


init : Params -> Model
init params =
    { gridControl =
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



-- Encode


{-| http://stackoverflow.com/questions/38412720/how-to-encode-tuple-to-json-in-elm
-}
tuple2Encoder : (a -> Encode.Value) -> (b -> Encode.Value) -> ( a, b ) -> Encode.Value
tuple2Encoder enc1 enc2 ( val1, val2 ) =
    Encode.list [ enc1 val1, enc2 val2 ]


coordEncoder : ( Int, Int ) -> Encode.Value
coordEncoder =
    tuple2Encoder Encode.int Encode.int


cellEncoder : ( ( Int, Int ), Bool ) -> Encode.Value
cellEncoder =
    tuple2Encoder coordEncoder Encode.bool


cellsEncoder : Array ( ( Int, Int ), Bool ) -> Encode.Value
cellsEncoder cellsArray =
    Encode.array <| Array.map cellEncoder cellsArray
