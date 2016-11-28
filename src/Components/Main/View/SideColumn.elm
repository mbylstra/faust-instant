module Components.Main.View.SideColumn exposing (view)


-- html

import Html exposing (..)
import Html.Attributes exposing (..)

-- external libs

import HtmlHelpers exposing (aButton, maybeView, boolView)

-- import FaustProgram

import Components.Main.Types exposing (..)
import Components.Main.View.ProgramList as ProgramList

-- component views

import Icons exposing (addIcon)

view : Model -> Html Msg
view model =
    div [ class "side-column" ]
        [ div
            []
            [ aButton NewFile
                [ class "side-column-button" ]
                [ addIcon, text "New DSP File" ]
            ]
        , div [] [ ProgramList.view model ]
        ]
