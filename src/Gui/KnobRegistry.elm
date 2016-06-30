module Gui.KnobRegistry exposing
  ( init
  , Model
  , EncodedModel
  , getKnobValue
  , Msg(GlobalMouseUp, MousePosition, UpdateParamsForAll)
  , update
  , view
  , encode
  )

--------------------------------------------------------------------------------
-- IMPORT
--------------------------------------------------------------------------------

import Dict exposing (Dict)
import Html exposing (Html, div)
import Html.App as App

import Gui.Knob as Knob

--------------------------------------------------------------------------------
-- MODEL
--------------------------------------------------------------------------------

type alias ID = String
type alias Knobs = Dict ID Knob.Model
type alias Model =
  { knobs : Knobs
  , currentKnob : Maybe ID
  , mouse : { y : Int, yVelocity : Int}
  }

init : List (String, Knob.Params) -> Model
init knobSpecs =
  { knobs = List.map (\(name, params) -> (name, Knob.init params)) knobSpecs
      |> Dict.fromList
  , currentKnob = Nothing
  , mouse = { y = 0, yVelocity = 0}
  }


getKnob : Knobs -> ID -> Knob.Model
getKnob knobs id =
  case (Dict.get id knobs) of
    Just knob -> knob
    Nothing -> Debug.crash("No knob exists with id: " ++ id)

getKnobValue : Model -> ID -> Float
getKnobValue model id =
  let
    knob = getKnob model.knobs id
  in
    knob.value

type alias EncodedModel =
  List (String, Knob.EncodedModel)

encode : Model -> EncodedModel
encode model =
  model.knobs
  |> Dict.map (\k v -> Knob.encode v)
  |> Dict.toList


--------------------------------------------------------------------------------
-- UPDATE
--------------------------------------------------------------------------------

type Msg
  = KnobMsg ID Knob.Msg
  | GlobalMouseUp
  | MousePosition (Int, Int)
  | UpdateParamsForAll Knob.Params


update : Msg -> Model -> Model
update action model =
  case action of
    KnobMsg id action' ->
      { model |
          knobs = Dict.update id (updateKnob action') model.knobs
        , currentKnob = Just id
      }

    MousePosition (x,y) ->
      let
        newMouse =
          { y = y
          , yVelocity = y - model.mouse.y
          }

      in
        case model.currentKnob of
          Just id ->
            { model |
                knobs = Dict.update
                  id
                  (updateKnob (Knob.MouseMove newMouse.yVelocity))
                  model.knobs
              , mouse = newMouse
            }
          Nothing ->
            { model | mouse = newMouse }

    GlobalMouseUp ->
      case model.currentKnob of
        Just id ->
          { model |
              knobs = Dict.update id (updateKnob Knob.GlobalMouseUp) model.knobs
              , currentKnob = Nothing
          }
        Nothing ->
          model

    UpdateParamsForAll params ->
      updateAllKnobs (Knob.UpdateParams params) model

updateAllKnobs : Knob.Msg -> Model -> Model
updateAllKnobs knobMsg model =
  let
    knobs =
      Dict.map
        (\id model -> Knob.update knobMsg model)
        model.knobs
  in
    { model | knobs = knobs }

updateKnob : Knob.Msg -> Maybe Knob.Model -> Maybe Knob.Model
updateKnob action =
  let
    updateKnob' : Maybe Knob.Model -> Maybe Knob.Model
    updateKnob' knob =
      case knob of
        Just knob' ->
          Just (Knob.update action knob')
        Nothing ->
          Nothing
  in
    updateKnob'


--------------------------------------------------------------------------------
-- VIEW
--------------------------------------------------------------------------------

view : Model -> ID -> Html Msg
view model id =
  let
    knob = getKnob model.knobs id
  in
    App.map (KnobMsg id) (Knob.view knob)
