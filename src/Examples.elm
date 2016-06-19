module Examples exposing (Model, Msg, update, init, view)

import Util


import Html exposing
  -- delete what you don't need
  ( Html, div, span, img, p, a, h1, h2, h3, h4, h5, h6, h6, text
  , ol, ul, li, dl, dt, dd
  , form, input, textarea, button, select, option
  , table, caption, tbody, thead, tr, td, th
  , em, strong, blockquote, hr
  )
-- import Html.Attributes exposing
--   ( style, class, id, title, hidden, type', checked, placeholder, selected
--   , name, href, target, src, height, width, alt
--   )
import Html.Events exposing
  ( on, targetValue, targetChecked, keyCode, onBlur, onFocus, onSubmit
  , onClick, onDoubleClick
  , onMouseDown, onMouseUp, onMouseEnter, onMouseLeave, onMouseOver, onMouseOut
  )


-- MODEL

type alias Model = List (String, String)

examplesRaw : List (String, String)
examplesRaw =
  [ ( "White Noise"
    , """
      import("music.lib");
      process = noise;
      """
    )
  , ( "Whistling Noise"
    , """
      import("music.lib");
      import("effect.lib");

      filterQ = 0.97;
      filterFrequency = 2000.0;
      process = noise : moog_vcf_2bn(filterQ, filterFrequency);
      """
    )
  , ( "Sine with vibrato"
    , """
      import("music.lib");
      import("effect.lib");

      lfoDepth = 10.0;
      lfoFreq = 3.0;
      lfo = osc(lfoFreq) * lfoDepth;

      process = osc(440.0 + lfo);
      """
    )
  , ( "\"Pulse Width Modulation Synthesis\""
    , """
      music = library("music.lib");
      oscillator = library("oscillator.lib");
      supercollider = library("sc.lib");


      process = supercollider.lfpulse(pulseFrequency, initialPulsePhase, pulseWidth);
      pulseFrequency = 440.0;
      initialPulsePhase = 0.0;
      pulseWidth = 0.5 + pulseWidthModulator;

      pulseWidthModulatorFrequency = 110.0;
      pulseWidthModulator = oscillator.osc(pulseWidthModulatorFrequency) * timbreLfo;

      timbreLfoFrequency = 0.7;
      timbreLfoRange = 0.4;
      timbreLfo = oscillator.osc(timbreLfoFrequency) * timbreLfoRange;
      """
    )
  , ( "Basic Saw wave implementation"
    , """
      periodInSamples = 44100 / 440.0;
      increasingInts = 1 : + ~ _ : _ - 1;
      normalize(maximum, value) = (value/maximum)*2 - 1;
      repeatingRamp = increasingInts % periodInSamples;
      process = repeatingRamp : normalize(periodInSamples - 1);
      """
    )
  , ( "Noise with Slider"
    , """
      import ("music.lib");
      // noise level controlled by a slider
      process = noise * vslider("volume", 0, 0, 1, 0.1);
      """
    )
  , ( "Sine with keyboard pitch"
    , """
      import ("music.lib");
      freq = nentry("freq", 440, 20, 20000, 1);
      process = osc(freq);
      """
    )




-- freq = nentry("freq[unit:Hz]", 440, 20, 20000, 1);

  ]


init : Model
init =
  examplesRaw
  |> List.map (\(key, value) -> (key, Util.unindent value))


-- UPDATE



-- UPDATE

type Msg
  = ExampleSelected String

update : Msg -> Model -> (Model, String)
update action model =
  case action of
    ExampleSelected s ->
      (model, s)



-- VIEW

buttonView : (String, String) -> Html Msg
buttonView (name, example) =
  button
    [ onClick (ExampleSelected example) ]
    [ text name ]

view : Model -> Html Msg
view model =
  let
    buttons = List.map buttonView model
  -- let
  --   List.map (\(key, value) ->
  in
    div [] buttons
