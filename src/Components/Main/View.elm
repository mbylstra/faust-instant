module Main.View exposing (..)

-- core
import Array exposing (Array)
import String
import Result
import Json.Decode

-- html
import Html.App as App
import Html exposing
  -- delete what you don't need
  ( Html, div, span, img, p, a, h1, h2, h3, h4, h5, h6, h6, text
  , ol, ul, li, dl, dt, dd
  , form, input, textarea, button, select, option
  , table, caption, tbody, thead, tr, td, th
  , em, strong, blockquote, hr, label
  )
import Html.Attributes exposing
  ( style, class, id, title, hidden, type', checked, placeholder, selected
  , name, href, target, src, height, width, alt, value, defaultValue
  )
import Html.Events exposing
  ( on, targetValue, targetChecked, keyCode, onBlur, onFocus, onSubmit, onInput
  , onClick, onDoubleClick
  , onMouseDown, onMouseUp, onMouseEnter, onMouseLeave, onMouseOver, onMouseOut
  )


-- external libs
import HtmlHelpers exposing (aButton, maybeView)

-- external components
import SignupView exposing
  ( OutMsg(SignUpButtonClicked, SignInButtonClicked)
  )

-- project components
import SliderNoModel
import Piano
import Color
import GoogleSpinner
import FaustControls
import User
-- import FaustProgram
import FaustControls
import Main.View.ProgramList as ProgramList
import MeasureText

-- component modules
-- import Main.Http.Firebase as FirebaseHttp

import Main.Types exposing (..)
import Main.Constants exposing (defaultBufferSize)

-- component views
import Main.View.UserMenu as UserMenu
import Main.View.UserSettingsDialog as UserSettingsDialog

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

bufferSizes : List Int
bufferSizes =
  [ 256, 512, 1024, 2048, 4096 ]  -- Note web audio requires a minimum of 256


getBufferSizeMillis : Int -> Int
getBufferSizeMillis bufferSize =
  Basics.round ((1.0 / Main.Constants.sampleRate) * (toFloat bufferSize) * 1000.0)


-- VIEW

view : Model -> Html Msg
view model =

  let
    _ = Debug.log "width:" model.textMeasurementWidth
    sliders =
      let
        renderSlider i uiInput =
          label [ class "slider-container" ]
            [ SliderNoModel.view
                { min = uiInput.min, max = uiInput.max, step = uiInput.step }
                (SliderChanged i)
                uiInput.init
            , span [] [text uiInput.label]
            ]
      in
        Array.indexedMap renderSlider model.uiInputs |> Array.toList
  in
    div [ class "main-wrap" ]
      [ MeasureText.view
      , UserSettingsDialog.view model
      , div [ class "main-header" ]
        [ div [ class "main-header-left" ]
            [ h1 [] [ text "Faust Instant" ] ]
        , div [ class "main-header-right" ]
            ( case model.user of
                Just user ->
                  [ User.view user
                  , UserMenu.view MDL model.mdl
                  ]
                Nothing ->
                  [ aButton (SignupViewMsg SignupView.OpenSignInDialog) [] [ text "Log In" ]
                  , aButton (SignupViewMsg SignupView.OpenSignUpDialog) [] [ text "Sign Up" ]
                  ]
            )
        ]
      , div [ class "main-row" ]
        [ div [ class "code-editor-column" ]
          [ div [ class "code-editor-top" ]
            [ div [ class "code-header" ]
              [ input
                [ type' "text"
                , class "edit-title"
                , value model.faustProgram.title
                , style [("width", (toString <| (Maybe.withDefault 0 model.textMeasurementWidth) + 5 ) ++ "px")]
                , onInput TitleUpdated
                ]
                []
              , maybeView
                (\user -> h3 [] [ text <| "by " ++ user.displayName ])
                model.user
              ]
            , div [ class "code-editor-buttons" ]
              [ div [ class "spinner-holder" ]
                  [ if model.loading then GoogleSpinner.view else span [] [] ]
              , label [] [ text "Latency: "]
              , bufferSizeSelectView model
              , button [ onClick Compile ]
                [ text "Compile "
                , span [] [ text "(CTRL-ENTER)" ]
                ]
              , maybeView
                  (\_ -> aButton Save [ class "save-button" ] [ text "Save" ] )
                  model.user
              ]
            ]
          , div [ id "code-editor-holder", class "code-editor"]
            [ textarea
              [ id "codemirror" ]
              []
            ]
          ]
        , div [ class "examples"]
          [ ProgramList.view model ]
        ]
      , div [ class "main-footer" ]
        [ p []
            [ text (Maybe.withDefault "" model.compilationError) ]
        -- , App.map VolumeSliderMsg (Slider.view model.mainVolume)
        -- , p []
        --   [ text "Audio Meter Value: "
        --   , text (toString model.audioMeter)
        --   ]
        -- , App.map AudioMeterMsg (AudioMeter.view model.audioMeter)
        -- , FFTBarGraph.view model.fftData
        , div [ class "sliders" ] sliders
        , pianoView model
        ]
      , ( let
            defaults = SignupView.defaults
            config =
              { defaults |
                branding = Just <| h1 [] [ text "Faust Instant" ]
              , signUpEnticer = Just <| p [] [ text "Sign up to save, share & star Faust programs" ]
              }
          in
            SignupView.view config model.signupView |> App.map SignupViewMsg
        )
      ]

pianoView : Model -> Html Msg
pianoView model =
  if FaustControls.showPiano model.uiInputs then
    Piano.view { blackKey = Color.black, whiteKey = Color.white} 6 12 PianoKeyMouseDown
  else
    div [] []

bufferSizeSelectView : Model -> Html Msg
bufferSizeSelectView model =
  let
    renderOption bufferSize =
      option
        [ value (toString bufferSize), selected (bufferSize == model.bufferSize)]
        [ text ((toString (getBufferSizeMillis bufferSize)) ++ "ms") ]
    parseInt s =
      String.toInt s |> Result.toMaybe |> Maybe.withDefault defaultBufferSize

    onChange =
      on "change" (Json.Decode.map (\v -> BufferSizeChanged (parseInt v)) targetValue)
  in
    select
      [ onChange ]
      (List.map renderOption bufferSizes)
