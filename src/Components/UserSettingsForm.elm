module Components.UserSettingsForm exposing (Model, Msg, init, update, view)

import Html
    exposing
        -- delete what you don't need
        ( Html
        , div
        , span
        , img
        , p
        , a
        , h1
        , h2
        , h3
        , h4
        , h5
        , h6
        , h6
        , text
        , ol
        , ul
        , li
        , dl
        , dt
        , dd
        , form
        , input
        , textarea
        , button
        , select
        , option
        , table
        , caption
        , tbody
        , thead
        , tr
        , td
        , th
        , em
        , strong
        , blockquote
        , hr
        )
import Html.Attributes
    exposing
        ( style
        , class
        , id
        , title
        , hidden
        , type_
        , checked
        , placeholder
        , selected
        , name
        , href
        , target
        , src
        , height
        , width
        , alt
        , defaultValue
        )
import Html.Events
    exposing
        ( on
        , targetValue
        , targetChecked
        , keyCode
        , onBlur
        , onFocus
        , onSubmit
        , onClick
        , onDoubleClick
        , onMouseDown
        , onMouseUp
        , onMouseEnter
        , onMouseLeave
        , onMouseOver
        , onMouseOut
        , onInput
        )


-- IDEA:
--  why not just pass a copy of the model in?
-- It's a copy, so we won't muck with the current version.
-- then we return the copy, and the parent replaces the current one with
-- valiated copy!

import HtmlHelpers exposing (aButton, emptyHtml, labelledInput)
import Components.User as User


-- MODEL
-- design:
-- one model type, but we want to keep the state of the one in the server,
-- and then the new one, in case we want to revert (without needing to do a
-- server fetch - although maybe a server fetch is a better thing to do??
---   why is it better?)
-- the tricky thing is that the final type (with required fields) maybe different
-- to the temporary type for a new object, which may have nulls.
-- you can get around this with empty strings though.


type alias Model =
    { userModel : User.Model
    , errors_ : Errors
    , submitHitAtLeastOnce : Bool
    }


type Errors
    = AllGood
    | HasErrors { displayName : Maybe String }


init : User.Model -> Model
init userModel =
    { userModel = userModel
    , errors_ = validate userModel
    , submitHitAtLeastOnce = False
    }



-- UPDATE


type Msg
    = DisplayNameInput String
    | Submit



-- The idea here is that the parent isn't interested in the data until
-- valid data has been submitted.


update : Msg -> Model -> ( Model, Maybe User.Model )
update action model =
    case action of
        DisplayNameInput s ->
            let
                userModel =
                    model.userModel

                newUserModel =
                    { userModel | displayName = s }
            in
                ( { model | userModel = newUserModel, errors_ = validate newUserModel }, Nothing )

        Submit ->
            case model.errors_ of
                AllGood ->
                    ( model, Just model.userModel )

                HasErrors errors ->
                    ( model, Nothing )


validate : User.Model -> Errors
validate model =
    if model.displayName == "" then
        HasErrors { displayName = Just "Name is required" }
    else
        AllGood



-- VIEW


view : Model -> Html Msg
view model =
    form
        [ onSubmit Submit
        ]
        [ labelledInput
            "Name"
            (input
                [ type_ "text"
                , onInput DisplayNameInput
                , defaultValue model.userModel.displayName
                ]
                []
            )
        , aButton Submit [ class "button save-button" ] [ text "submit" ]
        ]
