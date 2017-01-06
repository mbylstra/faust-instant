module Components.PitchStepSequencer exposing (..)

import Html exposing (div, button, text, node, h2, p)
import Html.Attributes exposing (style, class)
import Html
import GridControl

import Components.Main.Types as MainTypes
import Components.StepSequencer.Types exposing (Model)

numBars : Int
numBars = 1

numKeys : Int
numKeys = 13

notesPerBar : Int
notesPerBar = 8

init : Model
init =
    { position = 0
    , gridControl = GridControl.init (notesPerBar * numBars) numKeys False
    }

advanceIt : Model -> (Model, Maybe MainTypes.Msg)
advanceIt model =
    let
        newPosition = (model.position + 1) % (numBars * notesPerBar)
        maybeValue = GridControl.valueAtColumn newPosition model.gridControl
        maybeMsg =
            case maybeValue of
                Just value ->
                    let
                        midiNote = 36 + (numKeys - value)
                    in
                        Just <| MainTypes.SetPitch (toFloat midiNote)
                Nothing ->
                    Nothing
    in
        ({ model | position = newPosition }, maybeMsg )


handleGridControlMsg : GridControl.Msg -> Model -> (Model, List GridControl.OutMsg)
handleGridControlMsg gridControlMsg model =
    let
        (gridControl, outMsgs) = GridControl.update gridControlMsg model.gridControl
    in
        ({ model | gridControl = gridControl }, outMsgs)


view : String -> Model -> Html.Html MainTypes.Msg
view className model =
    div [ class className ]
        [ Html.map MainTypes.GridControlMsg <|
            GridControl.view {columnGroupLength=2} model.gridControl
        ]
