module Main.Update exposing (..)

--------------------------------------------------------------------------------

-- core
import Array
import Task
import Json.Decode

-- project libs
import Util exposing (unsafeMaybe, unsafeResult)

-- external components
import SignupView exposing (OutMsg(SignUpButtonClicked, SignInButtonClicked))
import FirebaseAuth

-- project components
import FaustProgram
import HotKeys
import Slider
import Arpeggiator
import FaustControls
import User
import Examples

-- component modules
import Main.Types exposing (..)
import Main.Commands exposing (createCompileCommand)
import Main.Ports exposing
  ( updateFaustCode
  , updateMainVolume
  , layoutUpdated
  , setControlValue
  , setPitch
  )
import Main.Constants exposing (firebaseConfig)
import Main.Http.Firebase as FirebaseHttp

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case Debug.log "action:" action of
  -- case action of

    Compile ->
      { model | loading = True } ! [ createCompileCommand model ]

    CompilationError maybeRawMessage ->
      let
        message = case maybeRawMessage of
          Just rawMessage ->
            rawMessage
            -- |> String.dropLeft 6
            -- |> String.dropLeft 6
            |> Just
          Nothing ->
            Nothing
      in
        { model | compilationError = message, loading = False } ! []

    FaustCodeChanged s ->
      let
        faustProgram =  model.faustProgram
        newFaustProgram = { faustProgram | code = s }
      in
      { model | faustProgram = newFaustProgram } ! []

    HotKeysMsg msg ->
      -- I think you have to get HotKeys to update the model here!
      let
        (hotKeys, hotKeysCommand) = HotKeys.update msg model.hotKeys
        -- _ = Debug.log "hotKeys" hotKeys
        doCompile = hotKeys.controlShiftPressed
        commands = [ Cmd.map HotKeysMsg hotKeysCommand ] ++
          if doCompile
          then [ createCompileCommand model ]
          else []
        loading = if doCompile then True else model.loading
      in
        { model | hotKeys = hotKeys, loading = loading } ! commands

    -- FileReaderMsg msg ->
    --   model ! []

    ExamplesMsg msg ->
      let
        result = Examples.update msg model.examples
        (newModel, cmds) = case result.code of
          Just code ->
            let
              faustProgram = model.faustProgram
              newFaustProgram = { faustProgram | code = code }
              newModel' = { model | faustProgram = newFaustProgram, loading = True }
            in
              (newModel', [createCompileCommand newModel'])
          Nothing ->
            let
              newModel' = { model | loading = True }
            in
              (newModel', [])
      in
        newModel !
          ( [ updateFaustCode newModel.faustProgram.code
            , Cmd.map ExamplesMsg result.cmd
            ] ++ cmds
          )

    VolumeSliderMsg msg ->
      let
        newModel = { model | mainVolume = Slider.update msg model.mainVolume }
      in
        newModel ! [ updateMainVolume newModel.mainVolume ]

    NewFFTData fftData ->
      { model | fftData = fftData } ! []

    DSPCompiled jsonList ->
      let
        decodeJson json =
          json
          |> Json.Decode.decodeValue FaustControls.sliderDecoder
          |> unsafeResult
        sliders = List.map decodeJson jsonList |> Array.fromList
      in
        { model | uiInputs = sliders, loading = False } !
          [ layoutUpdated () ]
        -- Debug.log "newmodel" { model | uiInputs = uiInputs } ! []
        -- model ! []

    SliderChanged i value ->
      let
        uiInput = unsafeMaybe (Array.get i model.uiInputs)
        uiInput' = { uiInput | init = value }
      in
        { model | uiInputs = Array.set i uiInput' model.uiInputs }
          ! [ setControlValue (uiInput.address, value) ]

    PianoKeyMouseDown pitch ->
      let
        _ = Debug.log "pitch" pitch
      in
        model ! [ setPitch pitch ]

    BufferSizeChanged bufferSize ->
      let
        newModel = { model | bufferSize = bufferSize }
      in
        newModel ! [ createCompileCommand newModel ]

    ArpeggiatorMsg msg ->
      let
        (arp2, pitch) = Arpeggiator.update msg model.arpeggiator
        newModel = { model | arpeggiator = arp2 }
        -- _ = Debug.log "arp note" note
      in
        newModel ! [ setPitch (toFloat pitch) ]

    SignupViewMsg msg ->
      let
        (signupView, maybeOutMsg) = SignupView.update msg model.signupView

        facebookLoginTask = FirebaseAuth.facebookSignInWithPopup firebaseConfig
        githubLoginTask = FirebaseAuth.githubSignInWithPopup firebaseConfig
        performSignUpCommand = Task.perform Error Success githubLoginTask
        cmds =
          case maybeOutMsg of
            Just outMsg ->
              case outMsg of
                SignUpButtonClicked _ ->
                  [ performSignUpCommand ]
                SignInButtonClicked _ ->
                  [ performSignUpCommand ]

            Nothing -> []
            -- _ ->
            --   []
      in
        { model | signupView = signupView } ! cmds

    CurrentFirebaseUserFetched maybeFirebaseUser ->
      case maybeFirebaseUser of
        Just firebaseUser ->
          let
            user =
              { uid = firebaseUser.uid
              , displayName = firebaseUser.displayName
              , imageUrl = firebaseUser.photoURL
              }
          in
            { model | user = Just user, authToken = Just firebaseUser.token } ! []
        Nothing ->
          model ! []

    Success firebaseUser ->
      let
        user =
          { uid = firebaseUser.uid
          , displayName = firebaseUser.displayName
          , imageUrl = firebaseUser.photoURL
          }
        task = FirebaseHttp.putUser firebaseUser.token firebaseUser.uid user
        cmd = Task.perform (\_ -> GeneralError) (\_ -> SuccessfulPut Nothing) task
      in
        { model | user = Just user, authToken = Just firebaseUser.token }
          ! [ cmd
            ]


    SuccessfulPut maybeString ->
      let
        _ = Debug.log "SuccessfulPut" 1
      in
        model ! []

    GeneralError ->
      let
        _ = Debug.log "GeneralError" 1
      in
        model ! []

    Error error ->
      model ! []

    -- Save ->
    --   case model.authToken of
    --     Just authToken ->
    --       let
    --         task = FirebaseHttp.postFaustProgram authToken model.faustProgram
    --         cmd = Task.perform (\_ -> GeneralError) FaustProgramPosted task
    --       in
    --         model ! [ cmd ]
    --     Nothing ->
    --       Debug.crash "we need to do something about save if user is not logged in"

    FaustProgramPosted key ->
      -- key is the newly generated key
      model ! []

    AuthTokenRetrievedFromLocalStorage authToken ->
      model ! []
      -- TODO: fetch user data so we can show the most up to date avatar (storing it in localstorage is a bad idea!)

    AuthTokenNotRetrievedFromLocalStorage _ ->
      model ! []

    _ ->
      Debug.crash ""
