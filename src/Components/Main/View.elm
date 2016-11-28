module Components.Main.View exposing (..)

-- html

import Html exposing (..)
import Html.Attributes exposing (..)

-- external components

import SignupView
    exposing
        ( OutMsg(SignUpButtonClicked, SignInButtonClicked)
        )

-- import FaustProgram

import Components.Main.Types exposing (..)
import Components.MeasureText as MeasureText

-- component views

import Components.Main.View.CodeEditorColumn as CodeEditorColumn
import Components.Main.View.UserSettingsDialog as UserSettingsDialog
import Components.Main.View.MainHeader as MainHeader
import Components.Main.View.MainFooter as MainFooter
import Components.Main.View.SideColumn as SideColumn


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- VIEW


view : Model -> Html Msg
view model =
    div [ class "main-wrap" ]
        (
            modalsHead model
            ++
            [ MainHeader.view model
            , div [ class "main-row" ]
                [ CodeEditorColumn.view model
                , SideColumn.view model
                ]
            , MainFooter.view model
            ]
            ++
            modalsFoot model
        )

modalsHead : Model -> List (Html Msg)
modalsHead model =
    [ MeasureText.view
    , UserSettingsDialog.view model
    ]

modalsFoot : Model -> List (Html Msg)
modalsFoot model =
    let
        defaults =
            SignupView.defaults

        config =
            { defaults
                | branding = Just <| h1 [] [ text "Faust Instant" ]
                , signUpEnticer = Just <| p [] [ text "Sign up to save, share & star Faust programs" ]
            }
    in
        [ SignupView.view config model.signupView |> Html.map SignupViewMsg ]
