module Components.Main.Http.Firebase exposing (..)

import Http
import FirebaseRest
import Components.User as User
import Components.FaustProgram as FaustProgram
import Components.Main.Constants as Constants

import Components.Main.Types exposing (..)


databaseUrlBase : String
databaseUrlBase =
    "https://faust-instant.firebaseio.com"


genericResultTagger : (data -> Msg) -> (( Result Http.Error data ) -> Msg)
genericResultTagger okTagger =
  (\result ->
    case result of
      Err error ->
        HttpError error
      Ok data ->
        okTagger data
  )

genericPutTagger : (( Result Http.Error data ) -> Msg)
genericPutTagger =
  (\result ->
    case result of
      Err error ->
        HttpError error
      Ok _ ->
        SuccessfulPut
  )


putUser
  : String
  -> String
  -> User.Model
  -> Cmd Msg
  -- -> Task.Task (HttpBuilder.Error String) (HttpBuilder.Response ())
putUser authToken id model =
    FirebaseRest.put databaseUrlBase "users" User.encoder genericPutTagger (Just authToken) id model


postFaustProgramTagger : Result Http.Error String -> Msg
postFaustProgramTagger result =
    case result of
        Err error ->
            HttpError error
        Ok key ->
            FaustProgramPosted key


postFaustProgram :
    String
    -> FaustProgram.Model
    -> Cmd Msg
postFaustProgram authToken model =
    let
        tagger = genericResultTagger FaustProgramPosted
    in
        FirebaseRest.post databaseUrlBase "faustPrograms" FaustProgram.encoder tagger (Just authToken) model


putFaustProgram :
    String
    -> String
    -> FaustProgram.Model
    -> Cmd Msg
putFaustProgram authToken id model =
    FirebaseRest.put databaseUrlBase "faustPrograms" FaustProgram.encoder genericPutTagger (Just authToken) id model


getFaustPrograms :
    List ( String, String )
    -> (List ( String, FaustProgram.Model ) -> Msg)
    -> Cmd Msg
getFaustPrograms params msgTagger =
    let
        tagger = genericResultTagger msgTagger
    in
        FirebaseRest.getMany databaseUrlBase "faustPrograms" FaustProgram.decoder params tagger Nothing


getFaustProgram :
    String
    -> (FaustProgram.Model -> Msg)
    -> Cmd Msg
getFaustProgram key msgTagger =
    let
        path =
            "faustPrograms/" ++ key
        resultTagger = genericResultTagger msgTagger
    in
        FirebaseRest.getOne databaseUrlBase path FaustProgram.decoder resultTagger Nothing


deleteFaustProgram :
    String
    -> String
    -> Cmd Msg
deleteFaustProgram authToken key =
    let
        path =
            "faustPrograms"
        tagger = genericPutTagger
    in
        FirebaseRest.delete databaseUrlBase path tagger (Just authToken) key


getStaffPicks : Cmd Msg
getStaffPicks =
    getFaustPrograms
        [ ( "orderBy", "\"staffPick\"" )
        , ( "equalTo", "true" )
        ]
        FetchedStaffPicks


getUserFaustPrograms :
    User.Model
    -> Cmd Msg
getUserFaustPrograms user =
    getFaustPrograms
        [ ( "orderBy", "\"author/uid\"" )
        , ( "equalTo", "\"" ++ user.uid ++ "\"" )
        ]
        FetchedUserPrograms


getTheDemoProgram : Cmd Msg
getTheDemoProgram =
    getFaustProgram Constants.theDemoProgramKey FetchedTheDemoProgram
