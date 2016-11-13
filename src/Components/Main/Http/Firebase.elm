module Components.Main.Http.Firebase exposing (..)

import FirebaseRest
import Task
import HttpBuilder

import Components.User as User
import Components.FaustProgram as FaustProgram

databaseUrlBase : String
databaseUrlBase = "https://faust-instant.firebaseio.com"

-- putUser
--   : String
--   -> String
--   -> User.Model
--   -> Task.Task (HttpBuilder.Error String) (HttpBuilder.Response ())
-- putUser authToken id model =
--   FirebaseRest.put databaseUrlBase "users" User.encoder (Just authToken) id model

postFaustProgram
  : String
  -> FaustProgram.Model
  -> Task.Task (HttpBuilder.Error String) String
postFaustProgram authToken model =
  FirebaseRest.post databaseUrlBase "faustPrograms" FaustProgram.encoder (Just authToken) model

putFaustProgram
  : String
  -> String
  -> FaustProgram.Model
  -> Task.Task (HttpBuilder.Error String) ()
putFaustProgram authToken id model =
  FirebaseRest.put databaseUrlBase "faustPrograms" FaustProgram.encoder (Just authToken) id model


getFaustPrograms
  : List (String, String)
  -> Task.Task (HttpBuilder.Error String) (List (String, FaustProgram.Model))
getFaustPrograms params =
  FirebaseRest.getMany databaseUrlBase "faustPrograms" FaustProgram.decoder params Nothing

getFaustProgram
  : String
  -> Task.Task (HttpBuilder.Error String) FaustProgram.Model
getFaustProgram key =
  let
    path = "faustPrograms/" ++ key
  in
    FirebaseRest.getOne databaseUrlBase path FaustProgram.decoder Nothing

getStaffPicks
  : Task.Task (HttpBuilder.Error String) (List (String, FaustProgram.Model))
getStaffPicks =
  getFaustPrograms
    [ ("orderBy", "\"staffPick\"")
    , ("equalTo", "true")
    ]

getUserFaustPrograms
  : User.Model
  -> Task.Task (HttpBuilder.Error String) (List (String, FaustProgram.Model))
getUserFaustPrograms user =
  getFaustPrograms
    [ ("orderBy", "\"author/uid\"")
    , ("equalTo", "\"" ++ user.uid ++ "\"")
    ]
