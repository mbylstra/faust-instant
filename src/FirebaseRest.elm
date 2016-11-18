module FirebaseRest exposing (..)

import Json.Decode exposing ((:=))
import Json.Encode
import Http
import Task exposing (Task)
import String

import HttpBuilder
-- import RemoteData

-- import Mbylstra.Maybe exposing (withEmptyListDefault)

-- auth = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjkxODI2N2I2MjVlODc1ZWM1MjNlZGVmNjlhMmZmYmQ3Yjc1ZmUyNDYifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vZWxtLWZpcmViYXNlLXNpbXBsZSIsIm5hbWUiOiJNaWNoYWVsIEJ5bHN0cmEiLCJwaWN0dXJlIjoiaHR0cHM6Ly9hdmF0YXJzLmdpdGh1YnVzZXJjb250ZW50LmNvbS91LzcwMjg4NT92PTMiLCJhdWQiOiJlbG0tZmlyZWJhc2Utc2ltcGxlIiwiYXV0aF90aW1lIjoxNDY3NTA4MjA0LCJ1c2VyX2lkIjoiMFBiYUlFRFpUeGd2QTNXT1c5cUFoWEJLTXh0MiIsInN1YiI6IjBQYmFJRURaVHhndkEzV09XOXFBaFhCS014dDIiLCJpYXQiOjE0Njc1MDgyMDUsImV4cCI6MTQ2NzUxMTgwNSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJnaXRodWIuY29tIjpbIjcwMjg4NSJdfX19.FZ13OPoYm6PzyIoqrHD716LIxMk2zBjCDEQRqru6ax5713Ubx2fxiMIpDsxMb0ncpJSpgTbLc24Y6gkqvp-RkxNNSw0o0Z1ayYWS6qd4YQE8-mL6s5eGc8ewEU25eFYMo8HkoLtFJFd0rgGbhqIXsyb5zwTEfS6iiJKPrcd8yVPT0LPUlU9Rwz-Vv_K4t2JhRuY9AWV0P37yU3UTDedoWIx8pj4WkIdy34bPr17wwPkuuIaiYCWBMEat7pQ3h401UraUm7hie_4bZl9dKqXIxYPIs2U7osxSS0AybFyBvaEHb7wbE-jyzzVr2eMyBt-t7M1nFgO3WFdzOqi_WsKw7A"
-- -- auth = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjkxODI2N2I2MjVlODc1ZWM1MjNlZGVmNjlhMmZmYmQ3Yjc1ZmUyNDYifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vZWxtLWZpcmViYXNlLXNpbXBsZSIsIm5hbWUiOiJNaWNoYWVsIEJ5bHN0cmEiLCJwaWN0dXJlIjoiaHR0cHM6Ly9hdmF0YXJzLmdpdGh1YnVzZXJjb250ZW50LmNvbS91LzcwMjg4NT92PTMiLCJhdWQiOiJlbG0tZmlyZWJhc2Utc2ltcGxlIiwiYXV0aF90aW1lIjoxNDY3NTA4MjA0LCJ1c2VyX2lkIjoiMFBiYUlFRFpUeGd2QTNXT1c5cUFoWEJLTXh0MiIsInN1YiI6IjBQYmFJRURaVHhndkEzV09XOXFBaFhCS014dDIiLCJpYXQiOjE0Njc1MDgyMDUsImV4cCI6MTQ2NzUxMTgwNSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJnaXRodWIuY29tIjpbIjcwMjg4NSJdfX19.FZ13OPoYm6PzyIoqrHD716LIxMk2zBjCDEQRqru6ax5713Ubx2fxiMIpDsxMb0ncpJSpgTbLc24Y6gkqvp-RkxNNSw0o0Z1ayYWS6qd4YQE8-mL6s5eGc8ewEU25eFYMo8HkoLtFJFd0rgGbhqIXsyb5zwTEfS6iiJKPrcd8yVPT0LPUlU9Rwz-Vv_K4t2JhRuY9AWV0P37yU3UTDedoWIx8pj4WkIdy34bPr17wwPkuuIaiYCWBMEat7pQ3h401UraUm7hie_4bZl9dKqXIxYPIs2U7osxSS0AybFyBvaEHb7wbE-jyzzVr2eMyBt-t7M1nFgO3WFdzOqi_WsKw7B"
-- userUid = "0PbaIEDZTxgvA3WOW9qAhXBKMxt2"
--
-- baseUrl = "https://elm-firebase-simple.firebaseio.com/"
-- path = "users/" ++ userUid
--
-- url = Http.url (baseUrl ++ path ++ ".json") [("auth", auth)]


-- type alias Config =
--   { databaseURL : String
--   , authToken : Maybe String
--   }


restUrl : String -> String -> List (String, String) -> Maybe String -> String
restUrl databaseUrl path params maybeAuthToken =
  let
    normalisedPath =
      if (String.startsWith "/" path == True) then path else ("/" ++ path)
  in
    Http.url
      ( databaseUrl ++ normalisedPath ++ ".json" )
      ( params ++
        ( case maybeAuthToken of
            Just authToken -> [("auth", authToken)]
            Nothing -> []
        )
      )


put :
  String
  -> String
  -> (model -> Json.Encode.Value)
  -> Maybe String
  -> String
  -> model
  -> Task (HttpBuilder.Error String) ()
put databaseUrl path encoder maybeAuthToken id model =
  let
    path' = path ++ "/" ++ id
    url = restUrl databaseUrl path' [] maybeAuthToken

    body : String
    body =
      Json.Encode.encode 0 (encoder model)

    task =
      HttpBuilder.put url
      |> HttpBuilder.withStringBody body
      |> HttpBuilder.send
          (HttpBuilder.jsonReader ignoreResponseBodyDecoder)
          HttpBuilder.stringReader
      |> Task.map .data
  in
    task

delete :
  String
  -> String
  -> Maybe String
  -> String
  -> Task (HttpBuilder.Error String) ()
delete databaseUrl path maybeAuthToken id =
  let
    path' = path ++ "/" ++ id
    url = restUrl databaseUrl path' [] maybeAuthToken

    task =
      HttpBuilder.delete url
      |> HttpBuilder.send
          (HttpBuilder.jsonReader ignoreResponseBodyDecoder)
          HttpBuilder.stringReader
      |> Task.map .data
  in
    task

post :
  String
  -> String
  -> (model -> Json.Encode.Value)
  -> Maybe String
  -> model
  -> Task (HttpBuilder.Error String) String
post databaseUrl path encoder maybeAuthToken model =
  let
    url = restUrl databaseUrl path [] maybeAuthToken

    body : String
    body =
      Json.Encode.encode 0 (encoder model)

    task =
      HttpBuilder.post url
      |> HttpBuilder.withStringBody body
      |> HttpBuilder.send
          (HttpBuilder.jsonReader keyResponseBodyDecoder)
          HttpBuilder.stringReader
      |> Task.map .data
  in
    task

getOne :
  String
  -> String
  -> Json.Decode.Decoder model
  -> Maybe String
  -> Task (HttpBuilder.Error String) model
getOne databaseUrl path decoder maybeAuthToken =
  let
    url = restUrl databaseUrl path [] maybeAuthToken
  in
    HttpBuilder.get url
    |> HttpBuilder.send
        (HttpBuilder.jsonReader decoder)
        HttpBuilder.stringReader
    |> Task.map .data

getMany :
  String
  -> String
  -> Json.Decode.Decoder model
  -> List (String, String)
  -> Maybe String
  -> Task (HttpBuilder.Error String) (List (String, model))
getMany databaseUrl path singleDecoder params maybeAuthToken =
  let
    url = restUrl databaseUrl path params maybeAuthToken
    manyDecoder = Json.Decode.keyValuePairs singleDecoder
  in
    HttpBuilder.get url
    |> HttpBuilder.send
        (HttpBuilder.jsonReader manyDecoder)
        HttpBuilder.stringReader
    |> Task.map .data


ignoreResponseBodyDecoder : Json.Decode.Decoder ()
ignoreResponseBodyDecoder =
  Json.Decode.succeed ()

keyResponseBodyDecoder : Json.Decode.Decoder String
keyResponseBodyDecoder =
  "name" := Json.Decode.string
