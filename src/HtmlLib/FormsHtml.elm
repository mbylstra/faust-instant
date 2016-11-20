module FormsHtml exposing (textInput, labelledTextInput)

import Html exposing (Html, input, Attribute, label, text)
import Html.Attributes exposing (type_, defaultValue)
import Html.Events exposing (onInput)


textInput : List (Attribute msg) -> (String -> msg) -> String -> Html msg
textInput attrs tagger defaultValue_ =
    input
        ([ type_ "text"
         , onInput tagger
         , defaultValue defaultValue_
         ]
            ++ attrs
        )
        []


labelledTextInput : (String -> msg) -> String -> String -> Html msg
labelledTextInput tagger labelText defaultValue_ =
    label
        []
        [ textInput [] tagger defaultValue_
        , text labelText
        ]
