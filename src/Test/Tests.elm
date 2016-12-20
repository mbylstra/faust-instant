
import Components.FaustUiModel exposing (faustUiDecoder, parseParams, FaustUi)
import Dict
import Expect exposing (..)
import Json.Decode exposing (decodeString)
import Test exposing (..)
import Test.Runner.Html

import Components.FaustUiModel exposing (parseParams, faustUiDecoder)

suite : Test
suite =
    describe "FaustUiModel.elm"
        [ describe "parseParams"
            [ test "successful parseParams" <|
                \() ->
                    let
                        params = "[key1: value1] [key2: value2]"
                    in
                        Expect.equal
                            (Dict.fromList [("key1","value1"),("key2","value2")])
                            (parseParams params)
            , test "badly formatted parseParams" <|
                \() ->
                    let
                        params = "[key1: value1] [key2 = value2]"
                    in
                        Expect.equal
                            (Dict.fromList [("key1","value1")])
                            (parseParams params)
            , test "faustUiDecoder" <|
                \() ->
                    let
                        example = """
                            {
                                "name": "test",
                                "outputs": "1",
                                "ui": [
                                    {
                                        "type": "vslider",
                                        "label": "1",
                                        "address": "",
                                        "init": "50",
                                        "min": "0",
                                        "max": "100",
                                        "step": "1"
                                    },
                                    {
                                        "type": "vgroup",
                                        "label": "2",
                                        "items": [
                                            {
                                                "type": "vslider",
                                                "label": "2-1",
                                                "address": "",
                                                "init": "50",
                                                "min": "0",
                                                "max": "100",
                                                "step": "1"
                                            }
                                        ]
                                    }
                                ]
                            }
                        """
                    in
                        Expect.equal
                            (decodeString faustUiDecoder example)
                            (Ok (FaustUi "test" "1" []))
            ]
        ]


main : Test.Runner.Html.TestProgram
main =
    [ suite
    ]
        |> concat
        |> Test.Runner.Html.run
