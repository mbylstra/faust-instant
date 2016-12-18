module Components.FaustUiModel exposing (..)

import Json.Decode as Decode exposing (..)
import Dict exposing (Dict)
import Regex exposing (Regex)

-- Model

type alias FaustUi =
    { name : String
    , address : String
    , port_ : String
    , ui : Ui
    }

type alias Ui = List UiNode

type UiNode =
    Input InputRecord
    | Group GroupRecord

type alias InputRecord =
    { label : String
    , inputType : InputType
    , address : String
    , init : String
    , min : String
    , max : String
    , step : String
    }

type InputType = VSlider | HSlider | Nentry | Checkbox

type alias GroupRecord =
    { label : String
    , type_ : GroupType
    , items : List UiNode
    }

type GroupType = HGroup | VGroup


-- Decoder

faustUiDecoder : Decoder FaustUi
faustUiDecoder =
    map4 FaustUi
        ( field "name" string )
        ( field "address" string )
        ( field "port" string )
        ( field "ui" uiDecoder )


uiDecoder : Decoder (List UiNode)
uiDecoder = list uiNodeDecoder


uiNodeDecoder : Decoder UiNode
uiNodeDecoder =
    oneOf [inputDecoder, groupDecoder]


inputDecoder : Decoder UiNode
inputDecoder =
    map7 InputRecord
        ( field "label" string )
        ( field "type" inputTypeDecoder )
        ( field "address" string )
        ( field "init" string )
        ( field "min" string )
        ( field "max" string )
        ( field "step" string )
    |> map Input


inputTypeDecoder : Decoder InputType
inputTypeDecoder =
    string
    |> andThen
        (\inputTypeString ->
            case inputTypeString of
                "vslider" -> succeed VSlider
                "hsider" -> succeed HSlider
                "nentry" -> succeed Nentry
                "checkbox" -> succeed Checkbox
                _ -> fail ("input type" ++ inputTypeString ++ " is not valid")
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
