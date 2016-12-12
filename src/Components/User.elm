module Components.User
    exposing
        ( Model
        , view
        , encoder
        , decoder
        , dummyModel
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as JsonDecode exposing (Decoder, field)
import Json.Encode as JsonEncode exposing (Value)
import Mbylstra.Json.Encode exposing (maybeString)
import HtmlHelpers exposing (maybeView)


-- MODEL


type alias Model =
    { uid : String
    , displayName : String
    , imageUrl : Maybe String
    , githubUsername : String
    }


dummyModel : Model
dummyModel =
    { uid = "abcdefg"
    , displayName = "Michael"
    , imageUrl = Nothing
    , githubUsername = "mbylstra"
    }



-- VIEW


view : Model -> Html msg
view user =
    let
        photo =
            maybeView (\url -> img [ src url, class "avatar" ] []) user.imageUrl

        displayName =
            span [] [ text user.displayName ]
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
        , ( "displayName", JsonEncode.string model.displayName )
        , ( "imageUrl", maybeString model.imageUrl )
        , ( "githubUsername", JsonEncode.string model.githubUsername )
        ]


decoder : Decoder Model
decoder =
    JsonDecode.map4 Model
        (field "uid" JsonDecode.string)
        (field "displayName" JsonDecode.string)
        (field "imageUrl" (JsonDecode.map Just JsonDecode.string))
        (field "githubUsername" JsonDecode.string)
