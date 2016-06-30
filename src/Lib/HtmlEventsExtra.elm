module Lib.HtmlEventsExtra exposing (..)

import Html.Events exposing (on, onWithOptions, Options)
import Html exposing (Attribute)
import Json.Decode

messageOnWithOptions : String -> Options -> msg -> Attribute msg
messageOnWithOptions name options message =
  onWithOptions name options (Json.Decode.succeed message)


messageOn : String -> msg -> Attribute msg
messageOn name message =
  on name (Json.Decode.succeed message)

onMouseDownWithOptions : Options -> msg -> Attribute msg
onMouseDownWithOptions options =
  messageOnWithOptions "mousedown" options

preventDefault : Options
preventDefault =
  { stopPropagation = False
  , preventDefault = True
  }
