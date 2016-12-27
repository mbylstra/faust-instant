module Components.Main.Update exposing (..)

--------------------------------------------------------------------------------
-- core
import Json.Decode
import Task

-- external packages
import Http exposing (Error(..))
import Update.Extra exposing (updateModel, andThen)
import Material

-- linked WIP external packages
import GridControl
import FirebaseAuth
import SignupView exposing (OutMsg(SignUpButtonClicked, SignInButtonClicked))

-- project libs
import Util exposing (unsafeMaybe, unsafeResult)


-- project components
import Components.HotKeys as HotKeys
import Components.Slider as Slider
import Components.SimpleDialog as SimpleDialog
import Components.Main.Model as Model exposing (firebaseUserLoggedIn)
import Components.Main.Types exposing (..)
import Components.Main.Commands
    exposing
        ( createCompileCommand
        , createCompileCommands
        , signOutFirebaseUser
        )
import Components.Main.Ports as Ports
    exposing
        ( updateFaustCode
        , updateMainVolume
        , layoutUpdated
        , setControlValue
        , measureText
        )
import Components.FaustProgram as FaustProgram
import Components.Main.Constants exposing (firebaseConfig)
import Components.Main.Http.Firebase as FirebaseHttp
    exposing
        ( getTheDemoProgram, deleteFaustProgram )
import Components.Main.Http.FaustFileStorage exposing (storeDspFile)
import Components.Midi as Midi
import Components.UserSettingsForm as UserSettingsForm
import Components.FaustUiModel as FaustUiModel exposing (faustUiDecoder)
import Components.StepSequencer as StepSequencer


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
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

        DSPCompiled json ->
            dspCompiled json model

        SliderChanged i value ->
            sliderChanged i value model

        FaustUiButtonDown address ->
            model ! [ setControlValue (address, 1.0) ]

        FaustUiButtonUp address ->
            model ! [ setControlValue (address, 0.0) ]

        PianoKeyMouseDown pitch ->
            pianoKeyMouseDown pitch model

        BufferSizeChanged bufferSize ->
            bufferSizeChanged bufferSize model

        -- ArpeggiatorMsg msg ->
        --     arpeggiatorMsg msg model

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
            ( model, Cmd.none )

        MDL msg_ ->
            Material.update msg_ model

        LogOutClicked ->
            model ! [ signOutFirebaseUser ]

        UserSignedOut ->
            { model | authToken = Nothing, user = Nothing } ! []

        UserSettingsDialogMsg msg_ ->
            userSettingsDialogMsg msg_ model

        OpenUserSettingsDialog ->
            openUserSettingsDialog model

        UserSettingsFormMsg msg_ ->
            userSettingsFormMsg msg_ model

        FetchedStaffPicks staffPicks ->
            fetchedStaffPicks staffPicks model

        FetchedUserPrograms faustPrograms ->
            fetchedUserPrograms faustPrograms model

        FetchedTheDemoProgram theDemoProgram ->
            fetchedTheDemoProgram theDemoProgram model

        OpenProgram faustProgram ->
            openProgram faustProgram model

        HttpError httpError ->
            handleHttpError httpError model

        TitleUpdated title ->
            titleUpdated title model

        NewTextMeasurement width ->
            newTextMeasurement width model

        WebfontsActive ->
            webfontsActive model

        BufferSnapshot bufferSnapshot ->
            handleBufferSnapshot bufferSnapshot model

        SvgUrlFetched url ->
            svgUrlFetched url model

        RawMidiInputEvent data ->
            rawMidiInputEvent data model

        MidiInputEvent midiEvent ->
            midiInputEvent midiEvent model

        GridControlMsg gridControlMsg ->
            handleGridControlMsg gridControlMsg model

        AudioBufferClockTick time ->
            handleAudioBufferClockTick time model

        MetronomeTick ->
            handleMetronomeTick model

        SetPitch pitch ->
            setPitch pitch model

        ToggleOnOff ->
            { model | on = not model.on } ! []

-- _ ->
--   Debug.crash ""
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


compile : Model -> ( Model, Cmd Msg )
compile model =
    { model | loading = True } ! (createCompileCommands model)


compilationError : Maybe String -> Model -> ( Model, Cmd Msg )
compilationError maybeRawMessage model =
    let
        message =
            case maybeRawMessage of
                Just rawMessage ->
                    rawMessage
                        -- |> String.dropLeft 6
                        -- |> String.dropLeft 6
                        |>
                            Just

                Nothing ->
                    Nothing
    in
        { model | compilationError = message, loading = False } ! []


faustCodeChanged : String -> Model -> ( Model, Cmd Msg )
faustCodeChanged s model =
    let
        faustProgram =
            model.faustProgram

        newFaustProgram =
            { faustProgram | code = s }
    in
        { model | faustProgram = newFaustProgram } ! [ measureText faustProgram.title ]


hotKeysMsg : HotKeys.Msg -> Model -> ( Model, Cmd Msg )
hotKeysMsg msg model =
    -- I think you have to get HotKeys to update the model here!
    let
        ( hotKeys, hotKeysCommand ) =
            HotKeys.update msg model.hotKeys

        doCompile =
            hotKeys.controlShiftPressed

        commands =
            [ Cmd.map HotKeysMsg hotKeysCommand ]
                ++ if doCompile then
                        createCompileCommands model
                   else
                        []

        loading =
            if doCompile then
                True
            else
                model.loading
    in
        { model | hotKeys = hotKeys, loading = loading } ! commands


volumeSliderMsg : Slider.Msg -> Model -> ( Model, Cmd Msg )
volumeSliderMsg msg model =
    let
        newModel =
            { model | mainVolume = Slider.update msg model.mainVolume }
    in
        newModel ! [ updateMainVolume newModel.mainVolume ]


dspCompiled : Json.Decode.Value -> Model -> ( Model, Cmd Msg )
dspCompiled json model =
    let
        faustUi =
            json
            |> Json.Decode.decodeValue faustUiDecoder
            |> unsafeResult
    in
        { model
        | faustUi = Just faustUi
        , faustUiInputs = FaustUiModel.extractUiInputs faustUi
        , loading = False
        }
        ! [ layoutUpdated () ]


sliderChanged : String -> Float -> Model -> ( Model, Cmd Msg )
sliderChanged address value model =
    -- { model
    -- TODO: actually update the faustUiInputs
    -- | faustUiInputs = Dict.insert address (value model.faustUiInputs
    -- }
    model
    !

    [ setControlValue ( address, value ) ]

setPitch : Float -> Model -> (Model, Cmd Msg)
setPitch pitch model =
    model ! [ Ports.setPitch pitch ]


pianoKeyMouseDown : Float -> Model -> ( Model, Cmd Msg )
pianoKeyMouseDown pitch model =
    model ! [ Ports.setPitch pitch ]


bufferSizeChanged : Int -> Model -> ( Model, Cmd Msg )
bufferSizeChanged bufferSize model =
    let
        newModel =
            { model | bufferSize = bufferSize }
    in
        newModel ! [ createCompileCommand newModel ]


-- arpeggiatorMsg : Arpeggiator.Msg -> Model -> ( Model, Cmd Msg )
-- arpeggiatorMsg msg model =
--     let
--         ( arp2, pitch ) =
--             Arpeggiator.update msg model.arpeggiator
--
--         newModel =
--             { model | arpeggiator = arp2 }
--
--     in
--         newModel ! [ Ports.setPitch (toFloat pitch) ]


signupViewMsg : SignupView.Msg -> Model -> ( Model, Cmd Msg )
signupViewMsg msg model =
    let
        ( signupView, maybeOutMsg ) =
            SignupView.update msg model.signupView

        facebookLoginTask =
            FirebaseAuth.facebookSignInWithPopup firebaseConfig

        githubLoginTask =
            FirebaseAuth.githubSignInWithPopup firebaseConfig

        performSignUpCommand =
            let
              tagger = \result ->
                case result of
                  Err error -> Error error
                  Ok data -> FirebaseLoginSuccess data
            in
                  Task.attempt tagger githubLoginTask

        cmds =
            case maybeOutMsg of
                Just outMsg ->
                    case outMsg of
                        SignUpButtonClicked _ ->
                            [ performSignUpCommand ]

                        SignInButtonClicked _ ->
                            [ performSignUpCommand ]

                Nothing ->
                    []

        -- _ ->
        --   []
    in
        { model | signupView = signupView } ! cmds


firebaseLoginSuccess : FirebaseAuth.User -> Model -> ( Model, Cmd Msg )
firebaseLoginSuccess firebaseUser model =
    let
        ( model2, cmd ) =
            firebaseUserLoggedIn firebaseUser model
    in
        model2 ! [ cmd ]


currentFirebaseUserFetched : Maybe FirebaseAuth.User -> Model -> ( Model, Cmd Msg )
currentFirebaseUserFetched maybeFirebaseUser model =
    case maybeFirebaseUser of
        Just firebaseUser ->
            let
                ( model2, cmd ) =
                    firebaseUserLoggedIn firebaseUser model
            in
                model2 ! [ cmd ]

        Nothing ->
            model ! [ getTheDemoProgram ]


successfulPut : Model -> ( Model, Cmd Msg )
successfulPut model =
    model ! []


generalError : Model -> ( Model, Cmd Msg )
generalError model =
    let
        _ =
            Debug.log "GeneralError" 1
    in
        model ! []


handleError : Model -> ( Model, Cmd Msg )
handleError model =
    model ! []


openUserSettingsDialog : Model -> ( Model, Cmd Msg )
openUserSettingsDialog model =
    let
        userSettingsDialog =
            SimpleDialog.update SimpleDialog.Open model.userSettingsDialog
    in
        { model | userSettingsDialog = userSettingsDialog } ! []


save : Model -> ( Model, Cmd Msg )
save model =
    case model.authToken of
        Just authToken ->
            let
                postProgramCmd =
                    case model.faustProgram.databaseId of
                        Just id ->
                            FirebaseHttp.putFaustProgram authToken id model.faustProgram

                        Nothing ->
                            FirebaseHttp.postFaustProgram authToken model.faustProgram
                -- let's also save to cloud at the same time. Ideally they'be done in series,
                -- but two fire n forget cmds is easier!


                commands =
                    case model.faustProgram.author of
                        Just author ->
                            [ postProgramCmd
                            , storeDspFile
                                { username = author.githubUsername
                                , filename = model.faustProgram.title
                                , code = model.faustProgram.code
                                }
                            ]
                        Nothing ->
                            [ postProgramCmd ]
            in
                model ! commands

        Nothing ->
            Debug.crash "We need to do something about save if user is not logged in"


newFile : Model -> ( Model, Cmd Msg )
newFile model =
    openProgram (FaustProgram.init model.user) model
        |> updateModel (\model -> { model | isDemoProgram = False })


deleteCurrentFile : Model -> ( Model, Cmd Msg )
deleteCurrentFile model =

    -- TODO: consider putting faustProgram in a union type like
    -- Unsaved, Saved, OwnedByUser, etc - which makes unpacking maybe's easier
    case model.faustProgram.databaseId of
        Just key ->
            case model.authToken of
                Just authToken ->
                    model ! [ deleteFaustProgram authToken key ]
                Nothing ->
                    Debug.crash "Unauthenticated user should not be abled to delete a db program"

        Nothing ->
            model ! []
                |> andThen update NewFile


faustProgramPosted : String -> Model -> ( Model, Cmd Msg )
faustProgramPosted key model =
    -- key is the newly generated key
    let
        faustProgram =
            model.faustProgram
    in
        { model | faustProgram = { faustProgram | databaseId = Just key } } ! []


userSettingsDialogMsg : SimpleDialog.Msg -> Model -> ( Model, Cmd Msg )
userSettingsDialogMsg msg_ model =
    let
        userSettingsDialog =
            SimpleDialog.update msg_ model.userSettingsDialog
    in
        { model | userSettingsDialog = userSettingsDialog } ! []


userSettingsFormMsg : UserSettingsForm.Msg -> Model -> ( Model, Cmd Msg )
userSettingsFormMsg msg_ model =
    case model.userSettingsForm of
        -- TODO: use elm-update-extra
        Just userSettingsForm ->
            let
                ( newUserSettingsForm, maybeUser ) =
                    UserSettingsForm.update msg_ userSettingsForm
            in
                case maybeUser of
                    Just user ->
                        let
                            updateUserProfileTask =
                                FirebaseAuth.updateUserProfile
                                    firebaseConfig
                                    { displayName = user.displayName, photoURL = user.imageUrl }

                            updateUserProfileCommand =
                                let
                                    tagger = \result ->
                                      case result of
                                        Err _ ->
                                          GeneralError
                                        Ok _ ->
                                          NoOp
                                in
                                    Task.attempt tagger updateUserProfileTask

                            userSettingsDialog =
                                SimpleDialog.update SimpleDialog.Close model.userSettingsDialog
                        in
                            { model
                                | user = Just user
                                , userSettingsDialog = userSettingsDialog
                                , userSettingsForm = Just newUserSettingsForm
                            }
                                ! [ updateUserProfileCommand ]

                    Nothing ->
                        { model | userSettingsForm = Just newUserSettingsForm } ! []

        Nothing ->
            model ! []


fetchedStaffPicks : List ( String, FaustProgram.Model ) -> Model -> ( Model, Cmd Msg )
fetchedStaffPicks staffPickPairs model =
    let
        staffPicks = FaustProgram.addIds staffPickPairs
    in
        { model | staffPicks = staffPicks } ! []



-- TODO: I think we need to add the db ids


fetchedUserPrograms : List ( String, FaustProgram.Model ) -> Model -> ( Model, Cmd Msg )
fetchedUserPrograms faustProgramPairs model =
    let
        faustPrograms = FaustProgram.addIds faustProgramPairs
        sortedPrograms =  List.sortBy .title faustPrograms
    in
        { model | myPrograms = sortedPrograms } ! []


fetchedTheDemoProgram : FaustProgram.Model -> Model -> ( Model, Cmd Msg )
fetchedTheDemoProgram theDemoProgram model =
    openProgram theDemoProgram model
        |> updateModel (\model -> { model | isDemoProgram = True })


openProgram : FaustProgram.Model -> Model -> ( Model, Cmd Msg )
openProgram faustProgram model =
    -- TOOD: for some reason DB ids aren't in here. Maybe because
    -- They aren't getting added when we fetch the results?
    let
        newModel =
            { model
                | faustProgram = faustProgram
                , loading = True
            }
        commands =
            [ updateFaustCode newModel.faustProgram.code
            , measureText newModel.faustProgram.title
            ]
             ++ createCompileCommands newModel
    in
        newModel ! commands



-- model
-- |> openProgram


handleHttpError : Http.Error -> Model -> ( Model, Cmd Msg )
handleHttpError httpError model =
    case httpError of
        NetworkError ->
            { model | online = False } ! []

        BadStatus httpError ->
            let
                _ = Debug.log "BadStatus" (toString httpError)
            in
                model ! []

        _ ->
            Debug.crash "HttpError"


titleUpdated : String -> Model -> ( Model, Cmd Msg )
titleUpdated title model =
    let
        faustProgram =
            model.faustProgram
    in
        { model
            | faustProgram =
                { faustProgram | title = title }
        }
            ! [ measureText title ]



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


newTextMeasurement : Int -> Model -> ( Model, Cmd Msg )
newTextMeasurement width model =
    { model | textMeasurementWidth = Just width } ! []


webfontsActive : Model -> ( Model, Cmd Msg )
webfontsActive model =
    model ! [ measureText model.faustProgram.title ]


handleBufferSnapshot : List Float -> Model -> (Model, Cmd Msg)
handleBufferSnapshot snapshot model =
    { model | bufferSnapshot = Just snapshot }  ! []

svgUrlFetched : String -> Model -> (Model, Cmd Msg)
svgUrlFetched url model =
    { model | faustSvgUrl = Just url } ! []


rawMidiInputEvent : ( Int, Int, Int ) -> Model -> ( Model, Cmd Msg )
rawMidiInputEvent data model =
    let
        midiMessage =
            Midi.parseRawMidiEvent data
    in
        case midiMessage of
            Midi.NoteOn ( midiNote, velocity ) ->
                model ! [ Ports.setPitch (toFloat midiNote) ]

            _ ->
                model ! []



-- in
-- -- model ! [Task.perform ? (Midi.parseRawMidiEvent data)] -- TODO: some shit with never and crap (should be a library function)
--   model ! [] -- TODO: some shit with never and crap (should be a library function)


midiInputEvent : Midi.MidiInputEvent -> Model -> ( Model, Cmd Msg )
midiInputEvent midiEvent model =
    case midiEvent of
        Midi.NoteOn ( midiNote, velocity ) ->
            model ! [ Ports.setPitch (toFloat midiNote) ]

        -- TODO something (like the piano keyboard)
        _ ->
            model ! []

handleGridControlMsg : GridControl.Msg -> Model -> ( Model, Cmd Msg )
handleGridControlMsg gridControlMsg model =
    let
        stepSequencer = StepSequencer.handleGridControlMsg gridControlMsg model.stepSequencer
    in
        { model | stepSequencer = stepSequencer } ! []


numberOfTicksPerBeat : Int
numberOfTicksPerBeat = 24


handleAudioBufferClockTick : Float -> Model -> (Model, Cmd Msg)
handleAudioBufferClockTick time model =
    let
        beatDuration = 1.0 / (model.tempo / 60.0)
        -- 6O BPM is 1 beat = 1 second
        -- 120 BPM is 1 beat = 0.5 seconds.

        metronomeTickDuration = beatDuration / (toFloat numberOfTicksPerBeat)
        nextMetronomeTickTime = model.lastMetronomeTickTime + metronomeTickDuration
    in
        if model.audioClockTime >= nextMetronomeTickTime
        then
            { model | audioClockTime = time, lastMetronomeTickTime = nextMetronomeTickTime } ! []
            |> andThen update MetronomeTick
        else
            { model | audioClockTime = time } ! []

handleMetronomeTick : Model -> (Model, Cmd Msg)
handleMetronomeTick model =
    let
        updateGlobalSongPosition : SongPosition -> SongPosition
        updateGlobalSongPosition songPosition =
            let
                { bar, beat, tick } = songPosition
                newTick = (tick + 1) % numberOfTicksPerBeat
            in
                if newTick == 0
                then
                    let
                        newBeat = songPosition.beat + 1 % (model.numberOfBeatsPerBar)
                    in
                        if newBeat == 0
                        then
                            { songPosition | bar = bar + 1, beat = 0, tick = 0 }
                        else
                            { songPosition | beat = newBeat, tick = 0 }
                else
                    { songPosition | tick = newTick }

        newSongPosition = updateGlobalSongPosition model.globalSongPosition
        model2 = { model | globalSongPosition = newSongPosition }
    in

        -- if tick falls on an eighth note, then we want to advance the step sequencer
        if newSongPosition.tick % 8 == 0
        then
            let
                (newStepSequencer, maybeMsg) = StepSequencer.advanceIt model.stepSequencer
                model3 = { model2 | stepSequencer = newStepSequencer }
            in
                case maybeMsg of
                    Just msg ->
                        update msg model3
                    Nothing ->
                        model3 ! []
        else
            model2 ! []
