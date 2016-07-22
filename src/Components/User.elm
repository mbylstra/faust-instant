module Components.User exposing
  ( Model
  , view
  , encoder
  , decoder
  )

import Html exposing (..)
import Html.Attributes exposing (..)

import Json.Decode as JsonDecode exposing (Decoder, (:=))
import Json.Encode as JsonEncode exposing (Value)

import Mbylstra.Json.Encode exposing (maybeString)

import HtmlHelpers exposing (maybeView)


-- MODEL

type alias Model =
  { uid : String
  , displayName : Maybe String
  , imageUrl : Maybe String
  }


-- VIEW

view : Model -> Html msg
view user =
  let
    photo =
      maybeView (\url -> img [ src url, class "avatar" ] []) user.imageUrl
    displayName =
      maybeView (\name -> span [] [ text name ]) user.displayName
  in
    div [ class "user" ]
      [ displayName
      , photo
      ]

-- SERIALIZE

encoder : Model -> Value
encoder model =
    JsonEncode.object
        [ ( "uid", JsonEncode.string model.uid )
        , ( "displayName", maybeString model.displayName )
        , ( "imageUrl", maybeString model.imageUrl )
        ]

decoder : Decoder Model
decoder =
    JsonDecode.object3 Model
        ("uid" := JsonDecode.string)
        ("displayName" := JsonDecode.map Just JsonDecode.string)
        ("imageUrl" := JsonDecode.map Just JsonDecode.string)
