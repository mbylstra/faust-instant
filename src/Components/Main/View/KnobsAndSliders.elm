-- module Components.Main.View.KnobsAndSliders exposing (view)
module Components.Main.View.KnobsAndSliders exposing (..)

-- import Array

import Html exposing (..)
import Html.Attributes exposing (..)

import Components.SliderNoModel as SliderNoModel

import Components.Main.Types exposing (..)
import Components.FaustUiModel as FaustUiModel exposing
    ( InputType(..)
    , UiNode(Input, Group)
    )

view : Model -> Html Msg
view model =
    case model.faustUi of
        Just faustUi ->
            div [ class "sliders" ] (faustUiView faustUi)
        Nothing ->
            div [] []


faustUiView : FaustUiModel.FaustUi -> List (Html Msg)
faustUiView faustUi =
    List.concatMap uiNodeView faustUi.ui

uiNodeView : FaustUiModel.UiNode -> List (Html Msg)
uiNodeView uiNode =
    case uiNode of
        Input input ->
            inputView input
        Group group ->
            groupView group

groupView : FaustUiModel.GroupRecord -> List (Html Msg)
groupView model =
    -- for now just render the inputs inside the group
    List.concatMap uiNodeView model.items


inputView : FaustUiModel.InputRecord -> List (Html Msg)
inputView model =
    case model.inputType of
        HSlider ->
            [ horizontalSliderView model ]
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
