module Components.Main.View.CodeEditorColumn exposing (..)

import HtmlHelpers exposing (aButton, maybeView, boolView)

import Html exposing
  -- delete what you don't need
  ( Html, div, span, img, p, a, h1, h2, h3, h4, h5, h6, h6, text
  , ol, ul, li, dl, dt, dd
  , form, input, textarea, button, select, option
  , table, caption, tbody, thead, tr, td, th
  , em, strong, blockquote, hr, label
  )
import Html.Attributes exposing
  ( value, style, class, id, title, hidden, type_, checked, placeholder, selected
  , name, href, target, src, height, width, alt
  )
import Html.Events exposing (..)

import Json.Decode

import Components.Main.Types exposing (..)
import Components.Main.Constants exposing (defaultBufferSize)
import Components.Main.View.FileSettingsMenu as FileSettingsMenu
import Components.Main.Model exposing (canSaveProgram)
import Components.GoogleSpinner as GoogleSpinner
import Components.Main.View.MiddleColumn as MiddleColumn

view : Model -> Html Msg
view model =
    div [ class "code-editor-column" ]
        [ div [ class "code-editor-top" ]
            [ div [ class "code-header" ]
                [ input
                    [ type_ "text"
                    , class "edit-title"
                    , value model.faustProgram.title
                    , style [ ( "width", (toString <| (Maybe.withDefault 0 model.textMeasurementWidth) + 5) ++ "px" ) ]
                    , onInput TitleUpdated
                    ]
                    []
                , maybeView
                    (\user -> h3 [] [ text <| "by " ++ user.displayName ])
                    model.faustProgram.author
                , boolView
                    (span [ class "demo-badge" ] [ text "demo" ])
                    model.isDemoProgram
                ]
            , div [ class "code-editor-buttons" ]
                [ div [ class "spinner-holder" ]
                    [ if model.loading then
                        GoogleSpinner.view
                      else
                        span [] []
                    ]
                , label [] [ text "Latency: " ]
                , bufferSizeSelectView model
                , button [ onClick Compile ]
                    [ text "Compile "
                    , span [] [ text "(CTRL-ENTER)" ]
                    ]
                , boolView
                    (aButton Save [ class "save-button" ] [ text "Save" ])
                    (canSaveProgram model)
                  -- , aButton Fork [ class "save-button" ] [ text "Fork" ]
                , FileSettingsMenu.view MDL model.mdl
                ]
            ]
        , div
            [ class "code-editor-main" ]

            [ div
                [ id "code-editor-holder", class "code-editor-holder" ]
                [ textarea [ id "codemirror" ] [] ]
            , MiddleColumn.view model
            ]
        ]


bufferSizeSelectView : Model -> Html Msg
bufferSizeSelectView model =
    let
        renderOption bufferSize =
            option
                [ value (toString bufferSize), selected (bufferSize == model.bufferSize) ]
                [ text ((toString (getBufferSizeMillis bufferSize)) ++ "ms") ]

        parseInt s =
            String.toInt s |> Result.toMaybe |> Maybe.withDefault defaultBufferSize

        onChange =
            on "change" (Json.Decode.map (\v -> BufferSizeChanged (parseInt v)) targetValue)
    in
        select
            [ onChange ]
            (List.map renderOption bufferSizes)

getBufferSizeMillis : Int -> Int
getBufferSizeMillis bufferSize =
    Basics.round ((1.0 / Components.Main.Constants.sampleRate) * (toFloat bufferSize) * 1000.0)

-- Note: web audio requires a minimum of 256
bufferSizes : List Int
bufferSizes =
    [ 256, 512, 1024, 2048, 4096 ]
