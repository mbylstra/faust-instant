module FaustProgram exposing
  ( Model
  , init
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
  }

init : Model
init =
  { databaseId = Nothing
  , code = ""
  , title = "Untitled"
  , public = False
  , authorUid = Nothing
  , starCount = 0
  }

-- SERIALIZE

encoder : Model -> Value
encoder model =
    JsonEncode.object
        [ ( "code", JsonEncode.string model.code )
        , ( "title", JsonEncode.string model.title )
        , ( "public", JsonEncode.bool model.public )
        , ( "authorUid", maybeString model.authorUid )
        , ( "starCount", JsonEncode.int model.starCount )
        ]

decoder : Decoder Model
decoder =
    JsonDecode.object6 Model
        (JsonDecode.succeed Nothing)
        ("code" := JsonDecode.string)
        ("title" := JsonDecode.string)
        ("public" := JsonDecode.bool)
        ("authorUid" := JsonDecode.maybe JsonDecode.string)
        ("starCount" := JsonDecode.int)
