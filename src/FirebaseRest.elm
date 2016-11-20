module FirebaseRest exposing (..)

import Json.Decode exposing (field)
import Json.Encode
import Http
import String
import HttpBuilder exposing (RequestBuilder)


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


type alias MsgTagger a msg =
  Result Http.Error a -> msg


restUrl : String -> String -> List ( String, String ) -> Maybe String -> (String, List (String, String))
restUrl databaseUrl path params maybeAuthToken =
    let
        normalisedPath =
            if (String.startsWith "/" path == True) then
                path
            else
                ("/" ++ path)
    in
        ( databaseUrl ++ normalisedPath ++ ".json"
        , params
              ++ (case maybeAuthToken of
                      Just authToken ->
                          [ ( "auth", authToken ) ]

                      Nothing ->
                          []
                 )
        )


put :
    String
    -> String
    -> (model -> Json.Encode.Value)
    -> MsgTagger () msg
    -> Maybe String
    -> String
    -> model
    -> Cmd msg
put databaseUrl subPath encoder tagger maybeAuthToken id model =
    let
        path =
            subPath ++ "/" ++ id

        (url, queryParams)=
            restUrl databaseUrl path [] maybeAuthToken
    in
        HttpBuilder.put url
            |> HttpBuilder.withQueryParams queryParams
            |> HttpBuilder.withJsonBody (encoder model)
            |> HttpBuilder.send tagger


delete :
    String
    -> String
    -> MsgTagger () msg
    -> Maybe String
    -> String
    -> Cmd msg
delete databaseUrl subPath tagger maybeAuthToken id =
    let
        path =
            subPath ++ "/" ++ id

        (url, queryParams) =
            restUrl databaseUrl path [] maybeAuthToken
    in
        HttpBuilder.delete url
            |> HttpBuilder.withQueryParams queryParams
            |> HttpBuilder.send tagger


post :
    String
    -> String
    -> (model -> Json.Encode.Value)
    -> MsgTagger String msg
    -> Maybe String
    -> model
    -> Cmd msg
post databaseUrl path encoder tagger maybeAuthToken model =
    let
        (url, queryParams) =
            restUrl databaseUrl path [] maybeAuthToken
    in
        HttpBuilder.post url
            |> HttpBuilder.withQueryParams queryParams
            |> HttpBuilder.withJsonBody (encoder model)
            |> HttpBuilder.withExpect (Http.expectJson keyResponseBodyDecoder)
            |> HttpBuilder.send tagger


getOne :
    String
    -> String
    -> Json.Decode.Decoder model
    -> (Result Http.Error model -> msg)
    -> Maybe String
    -> Cmd msg
getOne databaseUrl path decoder tagger maybeAuthToken =
    let
        (url, params) = restUrl databaseUrl path [] maybeAuthToken
    in
        HttpBuilder.get url
            |> HttpBuilder.withQueryParams params
            |> HttpBuilder.withExpect (Http.expectJson decoder)
            |> HttpBuilder.send tagger


getMany :
    String
    -> String
    -> Json.Decode.Decoder model
    -> List ( String, String )
    -> (Result Http.Error (List (String, model)) -> msg)
    -> Maybe String
    -> Cmd msg
getMany databaseUrl path singleDecoder params tagger maybeAuthToken =
    let
        (url, queryParams) =
            restUrl databaseUrl path params maybeAuthToken

        manyDecoder =
            Json.Decode.keyValuePairs singleDecoder
    in
        HttpBuilder.get url
            |> HttpBuilder.withQueryParams queryParams
            |> HttpBuilder.withExpect (Http.expectJson manyDecoder)
            |> HttpBuilder.send tagger


ignoreResponseBodyDecoder : Json.Decode.Decoder ()
ignoreResponseBodyDecoder =
    Json.Decode.succeed ()


keyResponseBodyDecoder : Json.Decode.Decoder String
keyResponseBodyDecoder =
    field "name" Json.Decode.string
