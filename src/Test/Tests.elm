import Test exposing (..)
import Expect exposing (..)
import Dict
import Test.Runner.Html

import Components.FaustUiModel exposing (parseParams)

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
            ]
        ]


main : Test.Runner.Html.TestProgram
main =
    [ suite
    ]
        |> concat
        |> Test.Runner.Html.run
