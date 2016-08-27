module Json.Encode.Extra exposing (maybeString)

import Json.Encode

maybeString : Maybe String -> Json.Encode.Value
maybeString maybeS =
  case maybeS of
    Just s ->
      Json.Encode.string s
    Nothing ->
      Json.Encode.null
