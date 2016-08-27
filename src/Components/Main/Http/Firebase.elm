module Main.Http.Firebase exposing (..)

import FirebaseRest
import Task
import HttpBuilder

-- import User
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
