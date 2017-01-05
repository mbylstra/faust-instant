module Components.Main.View.MainHeader exposing (view)

-- html

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

-- external libs

import HtmlHelpers exposing (aButton, maybeView, boolView)

-- external components

import SignupView
    exposing
        ( OutMsg(SignUpButtonClicked, SignInButtonClicked)
        )

-- project components

import Components.User as User

-- import FaustProgram

import Components.Main.Types exposing (..)
import Components.Main.View.UserMenu as UserMenu

-- component views


view : Model -> Html Msg
view model =
    div [ class "main-header" ]
        [ div [ class "main-header-left" ]
            [ h1 [] [ text "Faust Instant" ] ]
        -- , button [ onClick ToggleOnOff ] [ text "on/off"]
        , div [ class "main-header-right" ]
            (case model.user of
                Just user ->
                    [ User.view user
                    , UserMenu.view MDL model.mdl
                    ]

                Nothing ->
                    [ aButton (SignupViewMsg SignupView.OpenSignInDialog) [] [ text "Log In" ]
                    , aButton (SignupViewMsg SignupView.OpenSignUpDialog) [] [ text "Create Account" ]
                    ]
            )
        ]
