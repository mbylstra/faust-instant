module Misc exposing (unsafeDictGet, maybeEmptyString)

import Dict exposing(Dict)

unsafeDictGet : comparable -> Dict comparable value -> value
unsafeDictGet key dict =
  case Dict.get key dict of
    Just value ->
      value
    Nothing ->
      Debug.crash("Dict.get returned Nothing from within usafeDictGet")


maybeEmptyString : Maybe String -> String
maybeEmptyString maybeString =
  case maybeString of
    Just s -> s
    Nothing -> ""
