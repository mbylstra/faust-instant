module Components.StepSequencer exposing (..)

import Html exposing (div, button, text, node, h2, p)
import Html.Attributes exposing (style, class)
import Html
import GridControl

import Components.Main.Types as MainTypes
import Components.StepSequencer.Types exposing (Model)

numBars : Int
numBars = 2

numKeys : Int
numKeys = 13

notesPerBar : Int
notesPerBar = 8

init : Model
init =
    { position = 0
    , gridControl = GridControl.init (notesPerBar * numBars) numKeys
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


handleGridControlMsg : GridControl.Msg -> Model -> Model
handleGridControlMsg gridControlMsg model =
    let
        gridControl = GridControl.update gridControlMsg model.gridControl
    in
        { model | gridControl = gridControl }


view : Model -> Html.Html MainTypes.Msg
view model =
    div [ class "step-sequencer" ]
        [ Html.map MainTypes.GridControlMsg <|
            GridControl.view {columnGroupLength=notesPerBar} model.gridControl
        ]


-- get the value by
-- - get the column at x
-- - iterater through every value in the column, and take the last value
-- - of true ( I realise the model stinks a bit)
