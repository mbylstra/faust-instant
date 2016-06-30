module Lib.MouseExtra exposing
    -- ( velocity
    -- , xVelocity
    -- , yVelocity
    ( onMouseMove
    )


import Json.Decode exposing (..)
import Html.Events exposing(on)
import Html exposing(Attribute)
-- import Mouse


onMouseMove : ((Int, Int) -> msg) -> Attribute msg
onMouseMove handler =
  let
    -- mousePositionDecoder : Decoder msg
    mousePositionDecoder =
      object2
        (\x y -> handler (x,y))
        ("pageX" := int)
        ("pageY" := int)

    -- sendPosition : (Int, Int) -> msg
    -- sendPosition position =
    --   (handler position)

  in
    on "mousemove" mousePositionDecoder
