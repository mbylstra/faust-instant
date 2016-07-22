module FirebaseHttp exposing (..)

import FirebaseRest
import Task
import HttpBuilder

import Components.User as User
import Components.FaustProgram as FaustProgram

-- put databaseURL path encoder maybeAuthToken id model =

databaseUrl : String
databaseUrl = "https://faust-instant.firebaseio.com"

putUser
  : String
  -> String
  -> User.Model
  -> Task.Task (HttpBuilder.Error String) (HttpBuilder.Response ())
putUser authToken id model =
  FirebaseRest.put databaseUrl "users" User.encoder (Just authToken) id model

postFaustProgram
  : String
  -> FaustProgram.Model
  -> Task.Task (HttpBuilder.Error String) (HttpBuilder.Response String)
postFaustProgram authToken model =
  FirebaseRest.post databaseUrl "faustPrograms" FaustProgram.encoder (Just authToken) model
