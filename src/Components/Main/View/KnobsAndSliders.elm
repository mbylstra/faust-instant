-- module Components.Main.View.KnobsAndSliders exposing (view)
module Components.Main.View.KnobsAndSliders exposing (..)

-- import Array


import Dict exposing (Dict)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Components.SliderNoModel as SliderNoModel

import Components.Main.Types exposing (..)
import Components.FaustUiModel as FaustUiModel exposing
    ( InputType(..)
    , UiNode(Input, Group, Button, BarGraph)
    )

view : Model -> Html Msg
view model =
    case model.faustUi of
        Just faustUi ->
            div [ class "sliders" ] (faustUiView faustUi model.faustMeters)
        Nothing ->
            div [] []


faustUiView : FaustUiModel.FaustUi -> Dict String Float -> List (Html Msg)
faustUiView faustUi faustMeters =
    List.concatMap (uiNodeView faustMeters) faustUi.ui

uiNodeView : Dict String Float -> FaustUiModel.UiNode -> List (Html Msg)
uiNodeView faustMeters uiNode =
    case uiNode of
        Input input ->
            inputView input
        Button button ->
            [ buttonView button ]
        Group group ->
            groupView group faustMeters
        BarGraph barGraph ->
            let
                value = Dict.get barGraph.address faustMeters |> Maybe.withDefault 0.0
            in
                [ barGraphView barGraph value ]

groupView : FaustUiModel.GroupRecord -> Dict String Float -> List (Html Msg)
groupView model faustMeters =
    -- for now just render the inputs inside the group
    List.concatMap (uiNodeView faustMeters) model.items


inputView : FaustUiModel.InputRecord -> List (Html Msg)
inputView model =
    if model.label == "freq"
    then
        [] -- this will be rendered as a piano
    else
        case model.inputType of
            HSlider ->
                [ horizontalSliderView model ]
            -- Button ->
            --     [ buttonView model ]
            _ ->
                -- nothing else is implemented, so just use the horizonal slider
                [ horizontalSliderView model ]


horizontalSliderView : FaustUiModel.InputRecord -> Html Msg
horizontalSliderView model =
    label [ class "slider-container" ]
        [ SliderNoModel.view
            { min = model.min, max = model.max, step = model.step }
            (SliderChanged model.address)
            model.init
        , span [] [ text model.label ]
        ]

buttonView : FaustUiModel.ButtonRecord -> Html Msg
buttonView model =
    label [ class "button-container" ]
        [ button
            [ onMouseDown <| FaustUiButtonDown model.address
            , onMouseUp <| FaustUiButtonUp model.address
            ]
            [ text model.label]
        ]

barGraphView : FaustUiModel.BarGraphRecord -> Float -> Html Msg
barGraphView model value =
    label [ class "button-container" ]
        [ text (model.label ++ ": "), text <| toString value ]
