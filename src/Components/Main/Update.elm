module Components.Main.Update exposing (..)

--------------------------------------------------------------------------------

-- core
import Array
import Task
import Json.Decode

-- external libs

import HttpBuilder exposing (Error(..))
-- import Update.Extra.Infix exposing ((:>))
import Update.Extra exposing (updateModel)
import Maybe.Extra exposing (isJust)

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
    Compile ->
      compile model
    CompilationError maybeRawMessage ->
      compilationError maybeRawMessage model
    FaustCodeChanged s ->
      faustCodeChanged s model
    HotKeysMsg msg ->
      hotKeysMsg msg model
    VolumeSliderMsg msg ->
      volumeSliderMsg msg model
    DSPCompiled jsonList ->
      dspCompiled jsonList model
    SliderChanged i value ->
      sliderChanged i value model
    PianoKeyMouseDown pitch ->
      pianoKeyMouseDown pitch model
    BufferSizeChanged bufferSize ->
      bufferSizeChanged bufferSize model
    ArpeggiatorMsg msg ->
      arpeggiatorMsg msg model
    SignupViewMsg msg ->
      signupViewMsg msg model
    FirebaseLoginSuccess firebaseUser ->
      firebaseLoginSuccess firebaseUser model
    CurrentFirebaseUserFetched maybeFirebaseUser ->
      currentFirebaseUserFetched maybeFirebaseUser model
    SuccessfulPut ->
      successfulPut model
    GeneralError ->
      generalError model
    Error error ->
      handleError model
    Save ->
      save model
    Fork ->
      Debug.crash "TODO"
    NewFile ->
      newFile model
    DeleteCurrentFile ->
      deleteCurrentFile model
    FaustProgramPosted key ->
      faustProgramPosted key model
    MenuMsg idx action ->
      (model, Cmd.none)
    MDL msg' ->
      Material.update msg' model
    LogOutClicked ->
      model ! [ signOutFirebaseUser ]
    UserSignedOut ->
      { model | authToken = Nothing, user = Nothing } ! []
    UserSettingsDialogMsg msg' ->
      userSettingsDialogMsg msg' model
    OpenUserSettingsDialog ->
      openUserSettingsDialog model
    UserSettingsFormMsg msg' ->
      userSettingsFormMsg msg' model
    FetchedStaffPicks staffPicks ->
      fetchedStaffPicks staffPicks model
    FetchedUserPrograms faustPrograms ->
      fetchedUserPrograms faustPrograms model
    FetchedTheDemoProgram theDemoProgram ->
      fetchedTheDemoProgram theDemoProgram model
    OpenProgram faustProgram ->
      openProgram faustProgram model
    HttpBuilderError httpBuilderError ->
      handleHttpBuilderError httpBuilderError model
    TitleUpdated title ->
      titleUpdated title model
    NewTextMeasurement width ->
      newTextMeasurement width model
    WebfontsActive ->
      webfontsActive model
    RawMidiInputEvent data ->
      rawMidiInputEvent data model
    MidiInputEvent midiEvent ->
      midiInputEvent midiEvent model
    -- _ ->
    --   Debug.crash ""

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

compile : Model -> (Model, Cmd Msg)
compile model =
  { model | loading = True } ! [ createCompileCommand model ]


compilationError : Maybe String -> Model -> (Model, Cmd Msg)
compilationError maybeRawMessage model =
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


faustCodeChanged : String -> Model -> (Model, Cmd Msg)
faustCodeChanged s model =
  let
    faustProgram =  model.faustProgram
    newFaustProgram = { faustProgram | code = s }
  in
  { model | faustProgram = newFaustProgram } ! [ measureText faustProgram.title ]


hotKeysMsg : HotKeys.Msg -> Model -> (Model, Cmd Msg)
hotKeysMsg msg model =
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


volumeSliderMsg : Slider.Msg -> Model -> (Model, Cmd Msg)
volumeSliderMsg msg model  =
  let
    newModel = { model | mainVolume = Slider.update msg model.mainVolume }
  in
    newModel ! [ updateMainVolume newModel.mainVolume ]


dspCompiled : (List Json.Decode.Value) -> Model -> (Model, Cmd Msg)
dspCompiled jsonList model =
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


sliderChanged : Int -> Float -> Model -> (Model, Cmd Msg)
sliderChanged i value model =
  let
    uiInput = unsafeMaybe (Array.get i model.uiInputs)
    uiInput' = { uiInput | init = value }
  in
    { model | uiInputs = Array.set i uiInput' model.uiInputs }
      ! [ setControlValue (uiInput.address, value) ]


pianoKeyMouseDown : Float -> Model -> (Model, Cmd Msg)
pianoKeyMouseDown pitch model =
  let
    _ = Debug.log "pitch" pitch
  in
    model ! [ setPitch pitch ]

bufferSizeChanged : Int -> Model -> (Model, Cmd Msg)
bufferSizeChanged bufferSize model =
  let
    newModel = { model | bufferSize = bufferSize }
  in
    newModel ! [ createCompileCommand newModel ]


arpeggiatorMsg : Arpeggiator.Msg -> Model -> (Model, Cmd Msg)
arpeggiatorMsg msg model =
  let
    (arp2, pitch) = Arpeggiator.update msg model.arpeggiator
    newModel = { model | arpeggiator = arp2 }
    -- _ = Debug.log "arp note" note
  in
    newModel ! [ setPitch (toFloat pitch) ]


signupViewMsg : SignupView.Msg -> Model -> (Model, Cmd Msg)
signupViewMsg msg model =
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


firebaseLoginSuccess : FirebaseAuth.User -> Model -> (Model, Cmd Msg)
firebaseLoginSuccess firebaseUser model =
  let
    (model2, cmd) = firebaseUserLoggedIn firebaseUser model
  in
    model2 ! [cmd]


currentFirebaseUserFetched : (Maybe FirebaseAuth.User) -> Model -> (Model, Cmd Msg)
currentFirebaseUserFetched maybeFirebaseUser model =
  case maybeFirebaseUser of
    Just firebaseUser ->
      let
        (model2, cmd) = firebaseUserLoggedIn firebaseUser model
      in
        model2 ! [cmd]
    Nothing ->
      model ! [ fetchTheDemoProgram ]


successfulPut : Model -> (Model, Cmd Msg)
successfulPut model =
  let
    _ = Debug.log "SuccessfulPut" 1
  in
    model ! []


generalError : Model -> (Model, Cmd Msg)
generalError model =
  let
    _ = Debug.log "GeneralError" 1
  in
    model ! []


handleError : Model -> (Model, Cmd Msg)
handleError model =
  model ! []


openUserSettingsDialog : Model -> (Model, Cmd Msg)
openUserSettingsDialog model =
    let
      userSettingsDialog = SimpleDialog.update SimpleDialog.Open model.userSettingsDialog
    in
      { model | userSettingsDialog = userSettingsDialog } ! []


save : Model -> (Model, Cmd Msg)
save model =
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


newFile : Model -> (Model, Cmd Msg)
newFile model =
  openProgram (FaustProgram.init model.user) model
  |> updateModel (\model -> { model | isDemoProgram = False })

deleteCurrentFile : Model -> (Model, Cmd Msg)
deleteCurrentFile model =
  -- TODO!
  model ! []

faustProgramPosted : String -> Model -> (Model, Cmd Msg)
faustProgramPosted key model =
  -- key is the newly generated key
  let
    faustProgram = model.faustProgram

  in
    { model | faustProgram = { faustProgram | databaseId = Just key } } ! []


userSettingsDialogMsg : SimpleDialog.Msg -> Model -> (Model, Cmd Msg)
userSettingsDialogMsg msg' model =
  let
    userSettingsDialog = SimpleDialog.update msg' model.userSettingsDialog
  in
    { model | userSettingsDialog = userSettingsDialog } ! []


userSettingsFormMsg : UserSettingsForm.Msg -> Model -> (Model, Cmd Msg)
userSettingsFormMsg msg' model =
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



fetchedStaffPicks : (List (String, FaustProgram.Model)) -> Model -> (Model, Cmd Msg)
fetchedStaffPicks staffPicks model =
  -- TODO: I think we need to add the db ids
  { model | staffPicks = List.map snd staffPicks } ! []
  -- TODO: I think we need to add the db ids


fetchedUserPrograms :(List (String, FaustProgram.Model)) -> Model -> (Model, Cmd Msg)
fetchedUserPrograms faustPrograms model =
  { model | myPrograms = List.map snd faustPrograms } ! []


fetchedTheDemoProgram : FaustProgram.Model -> Model -> (Model, Cmd Msg)
fetchedTheDemoProgram theDemoProgram model =
  openProgram theDemoProgram model
  |> updateModel (\model -> { model | isDemoProgram = True })


openProgram : FaustProgram.Model -> Model -> (Model, Cmd Msg)
openProgram faustProgram model =
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


  -- model
  -- |> openProgram


handleHttpBuilderError : (HttpBuilder.Error String) -> Model -> (Model, Cmd Msg)
handleHttpBuilderError httpBuilderError model =
  case httpBuilderError of
    NetworkError ->
      { model | online = False } ! []
    _ ->
      Debug.crash (toString httpBuilderError)


titleUpdated : String -> Model -> (Model, Cmd Msg)
titleUpdated title model =
  let
    faustProgram = model.faustProgram
  in
    { model | faustProgram =
      { faustProgram | title = title }
    } ! [ measureText title ]

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
    -- NewFFTData fftData ->
    --   { model | fftData = fftData } ! []

newTextMeasurement : Int -> Model -> (Model, Cmd Msg)
newTextMeasurement width model =
  { model | textMeasurementWidth = Just width } ! []


webfontsActive : Model -> (Model, Cmd Msg)
webfontsActive model =
  model ! [ measureText model.faustProgram.title ]


rawMidiInputEvent : (Int, Int, Int) -> Model -> (Model, Cmd Msg)
rawMidiInputEvent data model =
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


midiInputEvent : Midi.MidiInputEvent -> Model -> (Model, Cmd Msg)
midiInputEvent midiEvent model =
  case midiEvent of
    Midi.NoteOn (midiNote, velocity) ->
      model ! [ setPitch (toFloat midiNote) ]
      -- TODO something (like the piano keyboard)
    _ ->
        model ! []
