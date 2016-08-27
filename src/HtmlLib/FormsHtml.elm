module FormsHtml exposing (textInput, labelledTextInput)

import Html exposing (Html, input, Attribute, label, text)
import Html.Attributes exposing (type', defaultValue)
import Html.Events exposing (onInput)


textInput : List (Attribute msg) -> (String -> msg) ->  String -> Html msg
textInput attrs tagger defaultValue' =
  input
    (
      [ type' "text"
      , onInput tagger
      , defaultValue defaultValue'
      ]
      ++ attrs
    )
    [ ]

labelledTextInput : (String -> msg) ->  String ->  String -> Html msg
labelledTextInput tagger labelText defaultValue' =
  label
    [ ]
    [ textInput [] tagger defaultValue'
    , text labelText
    ]
