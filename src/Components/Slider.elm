module Components.Slider exposing (Model, Msg, init, update, view)

import String
import Html exposing (Html, Attribute, div, input)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (on, targetValue)
import Json.Decode
import Result


-- MODEL


type alias Model =
    Float


init : Float -> Model
init value =
    value



-- UPDATE


type Msg
    = ValueUpdated Float


update : Msg -> Model -> Model
update action model =
    case action of
        ValueUpdated v ->
            v



-- VIEW


view : { min : Float, max : Float, step : Float } -> Float -> Html Msg
view attrs model =
    input
        [ type_ "range"
        , Html.Attributes.min (toString attrs.min)
        , Html.Attributes.max (toString attrs.max)
        , Html.Attributes.step (toString attrs.step)
        , value (toString model)
        , onSliderInput ValueUpdated
        ]
        []


onSliderInput : (Float -> msg) -> Attribute msg
onSliderInput tagger =
    let
        mapper =
            decodeSliderValue >> tagger
    in
        on
            "input"
            (Json.Decode.map mapper targetValue)


decodeSliderValue : String -> Float
decodeSliderValue result =
    (result
        |> String.toFloat
        |> Result.withDefault 0.0
    )
