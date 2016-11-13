module Components.FaustProgram exposing
  ( Model
  , init
  , default
  , hasAuthor
  , hasBeenSavedToDatabase
  , encoder
  , decoder
  )


import Maybe.Extra exposing (isNothing, isJust)

import Json.Decode as JsonDecode exposing (Decoder, (:=))
import Json.Encode as JsonEncode exposing (Value)

import Json.Encode.Extra exposing (maybeString, maybe)

import Components.User as User


-- MODEL

type alias Model =
  { databaseId : Maybe String
  , code : String
  , title : String
  , public : Bool
  , author : Maybe User.Model
  , starCount : Int
  , staffPick : Bool
  }


default : Model
default =
  { databaseId = Nothing
  , code = ""
  , title = "Untitled"
  , public = False
  , author = Nothing
  , starCount = 0
  , staffPick = False
  }

init : Model
init = default

hasAuthor : Model -> Bool
hasAuthor model =
  isJust model.author

hasBeenSavedToDatabase : Model -> Bool
hasBeenSavedToDatabase model =
  isJust (Debug.log "db id" model.databaseId)


-- SERIALIZE

encoder : Model -> Value
encoder model =
    JsonEncode.object
        [ ( "code", JsonEncode.string model.code )
        , ( "title", JsonEncode.string model.title )
        , ( "public", JsonEncode.bool model.public )
        , ( "author", maybe model.author User.encoder )
        , ( "starCount", JsonEncode.int model.starCount )
        , ( "staffPick", JsonEncode.bool model.staffPick )
        ]

decoder : Decoder Model
decoder =
    JsonDecode.object7 Model
        (JsonDecode.succeed Nothing)
          -- TODO: actually get the id, or store the id in the model, which
          -- would reuqire a subsequent PUT (a bit ugly)
        ("code" := JsonDecode.string)
        ("title" := JsonDecode.string)
        ("public" := JsonDecode.bool)
        ( JsonDecode.oneOf
          [ JsonDecode.map Just <| "author" := User.decoder
          , JsonDecode.succeed Nothing
          ]
        )
        ("starCount" := JsonDecode.int)
        ("staffPick" := JsonDecode.bool)
