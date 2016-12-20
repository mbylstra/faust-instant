module Components.StepSequencer exposing (..)

import Html exposing (div, button, text, node, h2, p)
import Html.Attributes exposing (style, class)
import Html
import GridControl

import Components.Main.Types exposing (..)

view : Model -> Html.Html Msg
view model =
  div [ class "step-sequencer" ]
    [ Html.map GridControlMsg <|
        GridControl.view {columnGroupLength=4} model.gridControl
    ]
