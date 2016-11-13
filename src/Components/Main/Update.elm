module Components.Main.Update exposing (..)

--------------------------------------------------------------------------------

-- core
import Array
import Task
import Json.Decode

-- external libs

import HttpBuilder exposing (Error(..))

-- project libs
import Util exposing (unsafeMaybe, unsafeResult)

-- external components
import SignupView exposing (OutMsg(SignUpButtonClicked, SignInButtonClicked))
import FirebaseAuth
import Material

-- project components
-- import FaustProgram
import Components.HotKeys as HotKeys
import Components.Slider as Slider
import Components.Arpeggiator as Arpeggiator
import Components.FaustControls as FaustControls
-- import User
import Components.SimpleDialog as SimpleDialog

-- component modules
import Components.Main.Model as Model exposing (firebaseUserLoggedIn)
import Components.Main.Types exposing (..)
import Components.Main.Commands exposing
  ( createCompileCommand
  , signOutFirebaseUser
  , fetchTheDemoProgram
  )
import Components.Main.Ports exposing
  ( updateFaustCode
  , updateMainVolume
  , layoutUpdated
  , setControlValue
  , setPitch
  , measureText
  )
import Components.FaustProgram as FaustProgram
import Components.Main.Constants exposing (firebaseConfig)
import Components.Main.Http.Firebase as FirebaseHttp
import Components.Midi as Midi

import Components.UserSettingsForm as UserSettingsForm
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  -- case Debug.log "action:" action of
  case action of

    NoOp ->
      model ! []
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
      { model | faustProgram = newFaustProgram } ! [ measureText faustProgram.title ]

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

    -- ExamplesMsg msg ->
    --   let
    --     result = Examples.update msg model.examples
    --     (newModel, cmds) = case result.code of
    --       Just code ->
    --         let
    --           faustProgram = model.faustProgram
    --           newFaustProgram = { faustProgram | code = code }
    --           newModel' = { model | faustProgram = newFaustProgram, loading = True }
    --         in
    --           (newModel', [createCompileCommand newModel'])
    --       Nothing ->
    --         let
    --           newModel' = { model | loading = True }
    --         in
    --           (newModel', [])
    --   in
    --     newModel !
    --       ( [ updateFaustCode newModel.faustProgram.code
    --         , Cmd.map ExamplesMsg result.cmd
    --         ] ++ cmds
    --       )

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
        performSignUpCommand = Task.perform Error FirebaseLoginSuccess githubLoginTask
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


    FirebaseLoginSuccess firebaseUser ->
      let
        (model2, cmd) = firebaseUserLoggedIn firebaseUser model
      in
        model2 ! [cmd]
    CurrentFirebaseUserFetched maybeFirebaseUser ->
      case maybeFirebaseUser of
        Just firebaseUser ->
          let
            (model2, cmd) = firebaseUserLoggedIn firebaseUser model
          in
            model2 ! [cmd]
        Nothing ->
          model ! [ fetchTheDemoProgram ]

    SuccessfulPut ->
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

    Save ->
      case model.authToken of
        Just authToken ->
          let
            cmd =
              case model.faustProgram.databaseId of
                Just id ->
                  let
                    task = FirebaseHttp.putFaustProgram authToken id model.faustProgram
                  in
                    Task.perform (\_ -> GeneralError) (\_ -> SuccessfulPut) task
                Nothing ->
                  let
                    task = FirebaseHttp.postFaustProgram authToken model.faustProgram
                  in
                    Task.perform (\_ -> GeneralError) FaustProgramPosted task
          in
            model ! [ cmd ]
        Nothing ->
          Debug.crash "We need to do something about save if user is not logged in"
    Fork ->
      Debug.crash "TODO"

    FaustProgramPosted key ->
      -- key is the newly generated key
      let
        faustProgram = model.faustProgram

      in
        { model | faustProgram = { faustProgram | databaseId = Just key } } ! []

    MenuMsg idx action ->
        (model, Cmd.none)

    MDL msg' ->
      Material.update MDL msg' model

    LogOutClicked ->
      model ! [ signOutFirebaseUser ]

    UserSignedOut ->
      { model | authToken = Nothing, user = Nothing } ! []

    UserSettingsDialogMsg msg' ->
      let
        userSettingsDialog = SimpleDialog.update msg' model.userSettingsDialog
      in
        { model | userSettingsDialog = userSettingsDialog } ! []

    OpenUserSettingsDialog ->
      let
        userSettingsDialog = SimpleDialog.update SimpleDialog.Open model.userSettingsDialog
      in
        { model | userSettingsDialog = userSettingsDialog } ! []

    UserSettingsFormMsg msg' ->
      case model.userSettingsForm of
        Just userSettingsForm ->
          let
            (userSettingsForm, maybeUser) = UserSettingsForm.update msg' userSettingsForm
          in
            case maybeUser of
              Just user ->
                let
                  updateUserProfileTask =
                    FirebaseAuth.updateUserProfile
                      firebaseConfig
                      { displayName = user.displayName , photoURL = user.imageUrl }
                  updateUserProfileCommand = Task.perform (\() -> NoOp) (\() -> NoOp) updateUserProfileTask
                  userSettingsDialog = SimpleDialog.update SimpleDialog.Close model.userSettingsDialog
                in
                  { model
                  | user = Just user
                  , userSettingsDialog = userSettingsDialog
                  , userSettingsForm = Just userSettingsForm
                  }
                  !
                  [ updateUserProfileCommand ]
              Nothing ->
                { model | userSettingsForm = Just userSettingsForm } ! []
        Nothing ->
          model ! []

    FetchedStaffPicks staffPicks ->
      -- TODO: I think we need to add the db ids
      { model | staffPicks = List.map snd staffPicks } ! []
      -- TODO: I think we need to add the db ids

    FetchedUserPrograms faustPrograms ->
      { model | myPrograms = List.map snd faustPrograms } ! []

    FetchedTheDemoProgram theDemoProgram ->
      openProgram model theDemoProgram

    OpenProgram faustProgram ->
      openProgram model faustProgram

    HttpBuilderError httpBuilderError ->
      case httpBuilderError of
        NetworkError ->
          { model | online = False } ! []
        _ ->
          Debug.crash (toString httpBuilderError)

    TitleUpdated title ->
      let
        faustProgram = model.faustProgram
      in
        { model | faustProgram =
          { faustProgram | title = title }
        } ! [ measureText title ]

    NewTextMeasurement width ->
      { model | textMeasurementWidth = Just width } ! []

    WebfontsActive ->
      model ! [ measureText model.faustProgram.title ]

    RawMidiInputEvent data ->
      let
        midiMessage = Midi.parseRawMidiEvent data
      in
        case midiMessage of
          Midi.NoteOn (midiNote, velocity) ->
            model ! [ setPitch (toFloat midiNote) ]
          _ ->
            model ! []
      -- in
      -- -- model ! [Task.perform ? (Midi.parseRawMidiEvent data)] -- TODO: some shit with never and crap (should be a library function)
      --   model ! [] -- TODO: some shit with never and crap (should be a library function)

    MidiInputEvent midiEvent ->
      case midiEvent of
        Midi.NoteOn (midiNote, velocity) ->
          model ! [ setPitch (toFloat midiNote) ]
          -- TODO something (like the piano keyboard)
        _ ->
          model ! []

    -- _ ->
    --   Debug.crash ""

openProgram : Model -> FaustProgram.Model -> (Model, Cmd Msg)
openProgram model faustProgram =
      -- TOOD: for some reason DB ids aren't in here. Maybe because
      -- They aren't getting added when we fetch the results?
  let
    newModel =
      { model
      | faustProgram = faustProgram
      , loading = True
      }
  in
    newModel !
      [ updateFaustCode newModel.faustProgram.code
      , createCompileCommand newModel
      , measureText newModel.faustProgram.title
        ]