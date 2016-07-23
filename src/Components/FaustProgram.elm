module FaustProgram exposing
  ( Model
  , init
  , encoder
  , decoder
  )

import Json.Decode as JsonDecode exposing (Decoder, (:=))
import Json.Encode as JsonEncode exposing (Value)


-- MODEL

type alias Model =
  { code : String
    -- key : Maybe String
  , title : String
  , public : Bool
  , author : String
  , starCount : Int
  }

init : Model
init =
  { code = ""
  -- , key = Nothing
  , title = "Untitled"
  , public = False
  , author = ""
  , starCount = 0
  }

-- SERIALIZE

encoder : Model -> Value
encoder model =
    JsonEncode.object
        [ ( "code", JsonEncode.string model.code )
        , ( "title", JsonEncode.string model.title )
        , ( "public", JsonEncode.bool model.public )
        , ( "author", JsonEncode.string model.author )
        , ( "starCount", JsonEncode.int model.starCount )
        ]

decoder : Decoder Model
decoder =
    JsonDecode.object5 Model
        ("code" := JsonDecode.string)
        ("title" := JsonDecode.string)
        ("public" := JsonDecode.bool)
        ("author" := JsonDecode.string)
        ("starCount" := JsonDecode.int)
