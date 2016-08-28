module FaustProgram exposing
  ( Model
  , init
  , default
  , encoder
  , decoder
  )

import Json.Decode as JsonDecode exposing (Decoder, (:=))
import Json.Encode as JsonEncode exposing (Value)

import Json.Encode.Extra exposing (maybeString)


-- MODEL

type alias Model =
  { databaseId : Maybe String
  , code : String
  , title : String
  , public : Bool
  , authorUid : Maybe String
  , starCount : Int
  , staffPick : Bool
  }

default : Model
default =
  { databaseId = Nothing
  , code = ""
  , title = "Untitled"
  , public = False
  , authorUid = Nothing
  , starCount = 0
  , staffPick = False
  }

init : Model
init = default

-- SERIALIZE

encoder : Model -> Value
encoder model =
    JsonEncode.object
        [ ( "code", JsonEncode.string model.code )
        , ( "title", JsonEncode.string model.title )
        , ( "public", JsonEncode.bool model.public )
        , ( "authorUid", maybeString model.authorUid )
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
          [ JsonDecode.map Just <| "authorUid" := JsonDecode.string
          , JsonDecode.succeed Nothing
          ]
        )
        ("starCount" := JsonDecode.int)
        ("staffPick" := JsonDecode.bool)
