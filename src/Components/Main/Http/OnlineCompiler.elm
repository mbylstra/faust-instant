module Components.Main.Http.OnlineCompiler exposing (getSvg)

import Components.Main.Types exposing (..)
import Http
import HttpBuilder

getSvgUrl : String
getSvgUrl = "http://michaelbylstra.com:8019/faust2svg"


-- TODO: put in library function
genericResultTagger : (data -> Msg) -> (( Result Http.Error data ) -> Msg)
genericResultTagger okTagger =
  (\result ->
    case result of
      Err error ->
        HttpError error
      Ok data ->
        okTagger data
  )

getSvg :
    (String -> Msg)
    -> String
    -> Cmd Msg
getSvg tagger faustCode =
    let
        resultTagger = genericResultTagger tagger

    in
        HttpBuilder.post getSvgUrl
            |> HttpBuilder.withStringBody "text/plain" faustCode
            |> HttpBuilder.withExpect Http.expectString
            |> HttpBuilder.send resultTagger
