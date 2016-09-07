module Json.Encode.Extra exposing (maybeString, maybe)

import Json.Encode

maybeString : Maybe String -> Json.Encode.Value
maybeString maybeS =
  case maybeS of
    Just s ->
      Json.Encode.string s
    Nothing ->
      Json.Encode.null

maybe : Maybe a -> (a -> Json.Encode.Value) -> Json.Encode.Value
maybe a encode =
  case a of
    Just a' ->
      encode a'
    Nothing ->
      Json.Encode.null
