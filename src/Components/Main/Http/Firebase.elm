module Main.Http.Firebase exposing (..)

import FirebaseRest
import Task
import HttpBuilder

import User
import FaustProgram

databaseUrl : String
databaseUrl = "https://faust-instant.firebaseio.com"

-- putUser
--   : String
--   -> String
--   -> User.Model
--   -> Task.Task (HttpBuilder.Error String) (HttpBuilder.Response ())
-- putUser authToken id model =
--   FirebaseRest.put databaseUrl "users" User.encoder (Just authToken) id model

postFaustProgram
  : String
  -> FaustProgram.Model
  -> Task.Task (HttpBuilder.Error String) String
postFaustProgram authToken model =
  FirebaseRest.post databaseUrl "faustPrograms" FaustProgram.encoder (Just authToken) model

putFaustProgram
  : String
  -> String
  -> FaustProgram.Model
  -> Task.Task (HttpBuilder.Error String) ()
putFaustProgram authToken id model =
  FirebaseRest.put databaseUrl "faustPrograms" FaustProgram.encoder (Just authToken) id model


getFaustPrograms
  : List (String, String)
  -> Task.Task (HttpBuilder.Error String) (List (String, FaustProgram.Model))
getFaustPrograms params =
  FirebaseRest.getMany databaseUrl "faustPrograms" FaustProgram.decoder params Nothing


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
    [ ("orderBy", "\"authorUid\"")
    , ("equalTo", user.uid)
    ]
