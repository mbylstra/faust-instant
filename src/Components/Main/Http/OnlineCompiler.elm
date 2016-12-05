module Components.Main.Http.OnlineCompiler exposing (getSvgUrl)

import Components.Main.Types exposing (..)
import Http
import HttpBuilder
import Json.Decode as Json

getSvgServiceUrl : String
getSvgServiceUrl = "http://michaelbylstra.com:8019/faust2svg"


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

getSvgUrl :
    (String -> Msg)
    -> String
    -> Cmd Msg
getSvgUrl tagger faustCode =
    let
        resultTagger = genericResultTagger tagger
        decoder = Json.field "url" Json.string

    in
        HttpBuilder.post getSvgServiceUrl
            |> HttpBuilder.withQueryParams
                [ ("stylesheet-href"
                , "http://michaelbylstra.com:8020/svg-diagram.css")
                ]
            |> HttpBuilder.withStringBody "text/plain" faustCode
            |> HttpBuilder.withExpect (Http.expectJson decoder)
            |> HttpBuilder.send resultTagger
