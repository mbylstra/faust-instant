module Components.Main.Http.FaustFileStorage exposing (storeDspFile)

import Components.Main.Types exposing (..)
import Http
import HttpBuilder

serviceUrl : String
serviceUrl = "http://files-api.faustinstant.net/store-dsp-file"


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

storeDspFile :
    { username : String, filename : String, code : String }
    -> Cmd Msg
storeDspFile { username, filename, code } =
    let
        resultTagger = genericResultTagger (\_ -> SuccessfulPut)
    in
        HttpBuilder.post serviceUrl
            |> HttpBuilder.withQueryParams
                [ ("username", username)
                , ("filename", filename)
                ]
            |> HttpBuilder.withStringBody "text/plain" code
            |> HttpBuilder.send resultTagger
