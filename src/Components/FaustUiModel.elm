module Components.FaustUiModel exposing (..)

import Json.Decode as Decode exposing (..)
import Dict exposing (Dict)
import Regex exposing (Regex)

import Util exposing (unsafeResult)


-- Model

type alias FaustUi =
    { name : String
    , outputs : String
    , ui : Ui
    }

type alias Ui = List UiNode

type UiNode =
    Input InputRecord
    -- Checkbox CheckboxRecord
    | BarGraph BarGraphRecord
    | Button ButtonRecord
    | Group GroupRecord
    -- | BarGraph

type alias InputRecord =
    { label : String
    , inputType : InputType
    , address : String
    , init : Float
    , min : Float
    , max : Float
    , step : Float
    }

type alias ButtonRecord =
    { label : String
    , address : String
    }

type alias BarGraphRecord =
    { label: String
    , address : String
    , min : Float
    , max :  Float
    }

-- type alias CheckboxRecord =
--     { label : String
--     , address : String
--     }

type InputType = VSlider | HSlider | Nentry

type alias GroupRecord =
    { label : String
    , groupType : GroupType
    , items : List UiNode
    }

type GroupType = HGroup | VGroup


type alias UiInputs = Dict String Float

-- Decoder

faustUiDecoder : Decoder FaustUi
faustUiDecoder =
    map3 FaustUi
        ( field "name" string )
        ( field "outputs" string )
        ( field "ui" uiDecoder )


uiDecoder : Decoder (List UiNode)
uiDecoder = list uiNodeDecoder


uiNodeDecoder : Decoder UiNode
uiNodeDecoder =
    oneOf [inputDecoder, groupDecoder, barGraphDecoder, buttonDecoder]


unsafeStringToFloat : String -> Float
unsafeStringToFloat s =
    s |> String.toFloat |> unsafeResult


inputDecoder : Decoder UiNode
inputDecoder =
    map7 InputRecord
        ( field "label" string )
        ( field "type" inputTypeDecoder )
        ( field "address" string )
        ( field "init" (map unsafeStringToFloat string))
        ( field "min" (map unsafeStringToFloat string))
        ( field "max" (map unsafeStringToFloat string))
        ( field "step" (map unsafeStringToFloat string))
    |> map Input

buttonDecoder : Decoder UiNode
buttonDecoder =
    map2 ButtonRecord
        ( field "label" string )
        ( field "address" string )
    |> map Button


barGraphDecoder : Decoder UiNode
barGraphDecoder =
    map4 BarGraphRecord
        ( field "label" string )
        ( field "address" string )
        ( field "min" (map unsafeStringToFloat string))
        ( field "max" (map unsafeStringToFloat string))
    |> map BarGraph

inputTypeDecoder : Decoder InputType
inputTypeDecoder =
    string
    |> andThen
        (\inputTypeString ->
            case inputTypeString of
                "vslider" -> succeed VSlider
                "hslider" -> succeed HSlider
                "nentry" -> succeed Nentry
                _ -> fail ("input type " ++ inputTypeString ++ " is not valid")
        )


groupDecoder : Decoder UiNode
groupDecoder =
    map3 GroupRecord
        ( field "label" string )
        ( field "type" groupTypeDecoder )
        ( field "items" <| list (lazy (\_ -> uiNodeDecoder)))
        |> map Group


groupTypeDecoder : Decoder GroupType
groupTypeDecoder =
    string
    |> andThen
        (\inputTypeString ->
            case inputTypeString of
                "hgroup" -> succeed HGroup
                "vgroup" -> succeed VGroup
                _ -> fail ("group type" ++ inputTypeString ++ " is not valid")
        )

type alias Params = Dict String String

-- Parse label metadata

parseParams : String -> Params
parseParams paramsString =
    let
        paramsRegex : Regex
        paramsRegex = Regex.regex "\\[\\s*(\\S*)\\s*\\:\\s*([^\\]]*)"
        matches = Regex.find Regex.All paramsRegex paramsString

        -- first we map to tuple, then convert to dict
        subMatchesToMaybeTuple : List (Maybe String) -> Maybe (String, String)
        subMatchesToMaybeTuple subMatches =
            -- we need to convert [Just "key1",Just "value1"] to ("key1", "value1")
            case subMatches of
                [match1, match2] ->
                    case match1 of
                        Just key ->
                            case match2 of
                                Just value ->
                                    Just (key, value)
                                Nothing ->
                                    Nothing
                        Nothing ->
                            Nothing
                _ ->
                    Nothing
    in
        matches
        |> List.filterMap (\match -> subMatchesToMaybeTuple match.submatches)
        |> Dict.fromList


parseLabel : String -> { label: String, params: Params }
parseLabel s =
    case String.split "[" s of
        label :: [] ->
            { label = String.trim label, params = Dict.empty }
        label :: paramsStringList ->
            let
                paramsString = String.concat paramsStringList
            in
                { label = String.trim label, params = parseParams paramsString }
        [] -> { label = "", params = Dict.empty }


--


extractUiInputs : FaustUi -> Dict String (Float, InputRecord)
extractUiInputs faustUi =
    -- here we need to walk the tree, finding inputs and adding them to the dict
    let
        processInput : InputRecord -> List (String, (Float, InputRecord))
        processInput input =
            [(input.address, (input.init, input) )]

        -- processButton : InputRecord -> List (String, (Float, InputRecord))
        -- processButton button =
        --     [(button.address, (input.init, input) )]

        processGroup group =
            processInputs group.items

        processInputs : List UiNode -> List (String, (Float, InputRecord))
        processInputs uiNodes =
            List.concatMap processUiNode uiNodes

        processUiNode : UiNode -> List (String, (Float, InputRecord))
        processUiNode uiNode =
            case uiNode of
                Input input ->
                    processInput input
                Group group ->
                    processGroup group
                Button button ->
                    [] -- for now we don't know about the state of the button, as we don't really need it
                BarGraph _ ->
                    []
                    -- processButton input

    in
        processInputs faustUi.ui
        |> Dict.fromList


getInitialMetersModel : FaustUi -> Dict String Float
getInitialMetersModel faustUi =
    -- here we need to walk the tree, finding inputs and adding them to the dict
    let
        processBarGraph : BarGraphRecord -> List String
        processBarGraph barGraph =
            [ barGraph.address ]

        processGroup group =
            processInputs group.items

        processInputs : List UiNode -> List String
        processInputs uiNodes =
            List.concatMap processUiNode uiNodes

        processUiNode : UiNode -> List String
        processUiNode uiNode =
            case uiNode of
                BarGraph barGraph ->
                    processBarGraph barGraph
                _ ->
                    []

    in
        processInputs faustUi.ui
        |> List.map (\address -> (address, 0.0))
        |> Dict.fromList


showPiano : Dict String (Float, InputRecord) -> Bool
showPiano uiInputs =
    Dict.values uiInputs
        |> List.filter (\(_, input) -> input.label == "_FI_pitchstepsequencer-value")
        |> List.length
        |> (==) 1

-- Example:
-- {
--     " name " : " mix4 " ,
--     " address " : " YannAir . local " ,
--     " port " : " 5511 " ,
--     " ui " : [
--         {
--             " type " : " hgroup " ,
--             " label " : " mixer " ,
--             " items " : [
--                 {
--                     " type " : " vgroup " ,
--                     " label " : " input_0 " ,
--                     " items " : [
--                         {
--                             " type " : " vslider " ,
--                             " label " : " level " ,
--                             " address " : " / mixer / input_0 / level " ,
--                             " init " : " 0" , " min " : " 0 " , " max " : " 1 " ,
--                             " step " : " 0.01 "
--                         } ,
--                         {
--                             " type " : " checkbox " ,
--                             " label " : " mute " ,
--                             " address " : " / mixer / input_0 / mute " ,
--                             " init " : " 0" , " min " : " 0 " , " max " : " 0 " ,
--                             " step " : " 0"
--                         }
--                     ]
--                 }
--             ]
--         }
--     ]
-- }
