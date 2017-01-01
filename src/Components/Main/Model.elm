module Components.Main.Model exposing (..)

--------------------------------------------------------------------------------
-- core

import Dict


-- external components

import SignupView


-- import LocalStorage

import FirebaseAuth
import Material


-- project components

import Components.FaustProgram as FaustProgram exposing (hasAuthor, hasBeenSavedToDatabase)
import Components.HotKeys as HotKeys
import Components.Slider as Slider
-- import Components.Arpeggiator as Arpeggiator
import Components.SimpleDialog as SimpleDialog
import Components.User as User
import Components.UserSettingsForm as UserSettingsForm


-- component modules

import Components.Main.Types exposing (..)
import Components.Main.Ports exposing (..)
import Components.Main.Constants as Constants
import Components.Main.Commands
    exposing
        ( fetchCurrentFirebaseUser
        )
import Components.Main.Http.Firebase exposing (getStaffPicks, getUserFaustPrograms)
import Components.StepSequencer as StepSequencer
import Components.DrumStepSequencer as DrumStepSequencer


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Init


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( hotKeys, hotKeysCommand ) =
            HotKeys.init
    in
        { on = False
        , faustProgram = FaustProgram.init Nothing
        , isDemoProgram = False
        , online =
            True
            -- assume we're online
        , compilationError = Nothing
        , hotKeys =
            hotKeys
            -- , fileReader = FileReader.init
        , mainVolume = Slider.init 1.0
        , fftData = []
        , faustUi = Nothing
        , faustUiInputs = Dict.empty
        , faustMeters = Dict.empty
        , polyphony = Monophonic
        , bufferSize = Constants.defaultBufferSize
        , loading = False
        -- , arpeggiator = Arpeggiator.init
        -- , arpeggiatorOn = False
        , signupView = SignupView.init
        , user = Nothing
        , authToken = Nothing
        , mdl = Material.model
        , userSettingsDialog = SimpleDialog.init
        , userSettingsForm = Nothing
        , staffPicks = []
        , myPrograms = []
        , textMeasurementWidth = Nothing
        , bufferSnapshot = Nothing
        , faustSvgUrl = Nothing
        , audioClockTime = 0.0
        , tempo = 120.0
        , lastMetronomeTickTime = 0.0
        , globalSongPosition = { bar = 0, beat = 0, tick = 0 }
        , numberOfBeatsPerBar = 4
        , stepSequencer = StepSequencer.init
        , drumStepSequencer = DrumStepSequencer.init
        }
            ! [ Cmd.map HotKeysMsg hotKeysCommand
              , elmAppInitialRender ()
              , fetchCurrentFirebaseUser
              , getStaffPicks
              , measureText "Untitled"
              ]


updateUser : Maybe User.Model -> Model -> Model
updateUser maybeUser model =
    let
        faustProgram =
            model.faustProgram
    in
        case maybeUser of
            Just user ->
                { model
                    | user = Just user
                    , faustProgram = { faustProgram | author = Just user }
                }

            Nothing ->
                { model
                    | user = Nothing
                    , faustProgram = { faustProgram | author = Nothing }
                }


isLoggedIn : Model -> Bool
isLoggedIn model =
    case model.user of
        Just _ ->
            True

        Nothing ->
            False


firebaseUserLoggedIn : FirebaseAuth.User -> Model -> ( Model, Cmd Msg )
firebaseUserLoggedIn firebaseUser model =
    let
        user =
            { uid = firebaseUser.uid
            , displayName = firebaseUser.displayName
            , imageUrl = firebaseUser.photoURL
            , githubUsername = firebaseUser.githubUsername
            }

        model2 =
            updateUser (Just user) model
    in
        ( { model2
            | userSettingsForm = Just <| UserSettingsForm.init user
            , authToken = Just firebaseUser.token
          }
        , getUserFaustPrograms user
        )


userOwnsProgram : User.Model -> FaustProgram.Model -> Bool
userOwnsProgram user faustProgram =
    case faustProgram.author of
        Just author ->
            if author.uid == user.uid then
                True
            else
                False

        Nothing ->
            False


canSaveProgram : Model -> Bool
canSaveProgram model =
    let
        faustProgram =
            model.faustProgram
    in
        not model.isDemoProgram
            && case model.user of
                Just user ->
                    if userOwnsProgram user faustProgram then
                        True
                    else
                        ( if Constants.saveStaffPicksMode then True else False )

                Nothing ->
                    if hasAuthor model.faustProgram then
                        False
                    else if hasBeenSavedToDatabase faustProgram then
                        False
                    else
                        True
