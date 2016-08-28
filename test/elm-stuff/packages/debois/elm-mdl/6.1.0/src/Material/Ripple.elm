module Material.Ripple exposing
  (..
  )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events
import Json.Decode as Json exposing ((:=), at)
import Platform.Cmd exposing (Cmd, none)

import Material.Helpers exposing (effect, fx, cssTransitionStep)
import DOM


-- MODEL


type alias Metrics =
  { rect : DOM.Rectangle
  , x : Float
  , y : Float
  }


type Animation
  = Frame Int -- There is only 0 and 1.
  | Inert


type alias Model =
  { animation : Animation
  , metrics : Maybe Metrics
  , ignoringMouseDown : Bool
  }


model : Model
model =
  { animation = Inert
  , metrics = Nothing
  , ignoringMouseDown = False
  }


-- ACTION, UPDATE


type alias DOMState =
  { rect : DOM.Rectangle
  , clientX : Maybe Float
  , clientY : Maybe Float
  , touchX : Maybe Float
  , touchY : Maybe Float
  , type' : String
  }


geometryDecoder : Json.Decoder DOMState
geometryDecoder =
  Json.object6 DOMState
    (DOM.target DOM.boundingClientRect)
    (Json.maybe ("clientX" := Json.float))
    (Json.maybe ("clientY" := Json.float))
    (Json.maybe (at ["touches", "0", "clientX"] Json.float))
    (Json.maybe (at ["touches", "0", "clientY"] Json.float))
    ("type" := Json.string)


computeMetrics : DOMState -> Maybe Metrics
computeMetrics g =
  let
    rect = g.rect
    set x y = (x - rect.left, y - rect.top) |> Just
  in
    (case (g.clientX, g.clientY, g.touchX, g.touchY) of
      (Just 0.0, Just 0.0, _, _) ->
        (rect.width / 2.0, rect.height / 2.0) |> Just

      (Just x, Just y, _, _) ->
        set x y

      (_, _, Just x, Just y) ->
        set x y

      _ ->
        Nothing

    ) |> Maybe.map (\(x,y) -> Metrics rect x y)


type Msg
  = Down DOMState
  | Up
  | Tick


update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    Down domState ->
      if domState.type' == "mousedown" && model.ignoringMouseDown then
        { model | ignoringMouseDown = False } |> effect none
      else
        { model
        | animation = Frame 0
        , metrics = computeMetrics domState
        , ignoringMouseDown = 
            if domState.type' == "touchstart" then
              True
            else
              model.ignoringMouseDown
        }
        |> effect (cssTransitionStep Tick)
           {- Issuing Tick immediately does not cause a CSS transition.
           Presumably, the principled way to proceed is to use
           elm-lang/animation-frame; but it's not entirely clear to me exactly
           how to do that in a way that'll be sufficiently convenient for 
           end-users. 
           -}

    Up ->
      { model
      | animation = Inert
      }
      |> effect none

    Tick ->
      { model
      | animation = Frame 1
      }
      |> effect none



-- VIEW


downOn : String -> Attribute Msg
downOn name =
  Html.Events.on name (Json.map Down geometryDecoder)


downOn' : (Msg -> m) -> String -> Attribute m
downOn' f name =
  Html.Events.on name (Json.map (Down >> f) geometryDecoder)


upOn : String -> Attribute Msg
upOn name =
  Html.Events.on name (Json.succeed Up) 


styles : Metrics -> Int -> List (String, String)
styles m frame =
  let
    scale = if frame == 0 then "scale(0.0001, 0.0001)" else ""
    toPx k = (toString (round k))  ++ "px"
    offset = "translate(" ++ toPx m.x ++ ", " ++ toPx m.y ++ ")"
    transformString = "translate(-50%, -50%) " ++ offset ++ scale
    r = m.rect
    rippleSize =
      sqrt (r.width * r.width + r.height * r.height) * 2.0 + 2.0 |> toPx
  in
    [ ("width", rippleSize)
    , ("height", rippleSize)
    , ("-webkit-transform", transformString)
    , ("-ms-transform", transformString)
    , ("transform", transformString)
    ]

{-| Add handlers yourself as attrs. -}
view' : List (Attribute Msg) -> Model -> Html Msg
view' attrs model =
  let
    styling =
      case (model.metrics, model.animation) of
        (Just metrics, Frame frame) -> styles metrics frame
        (Just metrics, Inert) -> styles metrics 1 -- Hack.
        _ -> []
  in
    span
      attrs
      [ span
        [ classList
          [ ("mdl-ripple", True)
          , ("is-animating", model.animation /= Frame 0)
          , ("is-visible", model.animation /= Inert)
          ]
        , style styling
        ]
        []
      ]


view : List (Attribute Msg) -> Model -> Html Msg
view =
  view' << flip List.append
    [ upOn "mouseup" 
    , upOn "mouseleave" 
    , upOn "touchend" 
    , upOn "blur" 
    , downOn "mousedown" 
    , downOn "touchstart" 
    ]


