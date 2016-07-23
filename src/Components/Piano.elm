module Piano exposing (view)

import Html exposing (..)
import Html.Attributes exposing(..)
import Html.Events exposing(onMouseDown, onMouseEnter, Options)
import Color exposing (Color)

-- import Lib.HtmlAttributesExtra exposing (..)
import ColorExtra exposing (toCssRgb)

pitchToFrequency : Float -> Float
pitchToFrequency pitch =
  2^((pitch - 49.0) / 12.0) * 440.0

-- it's acceptable to have a mailbox, as it's unlikely you'd ever need
-- more than one piano component simultaneously

-- pianoMailbox : Signal.Mailbox Float
-- pianoMailbox =  Signal.mailbox 60.0
--
-- pianoSignal : Signal Float
-- pianoSignal = pianoMailbox.signal

type KeyType = Black | White

type alias ColorScheme =
  { whiteKey: Color
  , blackKey: Color
  }

view : ColorScheme -> Int -> Float -> (Float -> msg) -> Html msg
view colorScheme numOctaves bottomPitch tagger =
  let
    bottomPitches =
      List.map (\n -> bottomPitch + (toFloat n)*12.0) [1..numOctaves]

    pianoOctaves =
      List.concatMap (\octaveBottomPitch -> pianoOctave octaveBottomPitch ) bottomPitches

    pianoKey keyType pitch =
      let
        _ = False
        -- tagger' pitch =
        --   tagger (pitchToFrequency pitch)
        --
      in
        case keyType of
          Black ->
            div [ class "black-key-wrapper"]
              [ div
                [ class "black-key"
                , onMouseEnter (tagger pitch)
                , style [("background-color", toCssRgb colorScheme.blackKey)]
                ]
                []
              ]
          White ->
            div
              [ class "white-key"
              , onMouseEnter (tagger pitch)
              , style [("background-color", toCssRgb colorScheme.whiteKey)]
              ]
              []

    pianoOctave cPitch =
      [ pianoKey White cPitch
      , pianoKey Black (cPitch + 1.0)
      , pianoKey White (cPitch + 2.0)
      , pianoKey Black (cPitch + 3.0)
      , pianoKey White (cPitch + 4.0)
      , pianoKey White (cPitch + 5.0)
      , pianoKey Black (cPitch + 6.0)
      , pianoKey White (cPitch + 7.0)
      , pianoKey Black (cPitch + 8.0)
      , pianoKey White (cPitch + 9.0)
      , pianoKey Black (cPitch + 10.0)
      , pianoKey White (cPitch + 11.0)
      ]

  in
    div [class "piano"]
        pianoOctaves

-- pianoGuiFrequency : Signal Float
-- pianoGuiFrequency =
--   Signal.map pitchToFrequency pianoSignal
