module Components.Arpeggiator exposing (Model, Msg, init, update, subscription)

import Time
import Array exposing (Array)
import Util exposing (unsafeMaybe)


-- MODEL


type Note
    = A
    | As
    | B
    | C
    | Cs
    | D
    | Ds
    | E
    | F
    | Fs
    | G
    | Gs


noteToInt : Note -> Int
noteToInt note =
    case note of
        A ->
            0

        As ->
            1

        B ->
            2

        C ->
            3

        Cs ->
            4

        D ->
            5

        Ds ->
            6

        E ->
            7

        F ->
            8

        Fs ->
            9

        G ->
            10

        Gs ->
            11


type alias Model =
    { keysDown : Array Int
    , tempo : Float
    , currPosition :
        Int
        -- A number from 0 - 15 (16 quarter notes)
    }


getChord : Model -> ( Note, Note, Note )
getChord model =
    ( C, Ds, E )



-- assumes minor triad for now


getCurrentNote : Model -> Int
getCurrentNote model =
    let
        ( triad1, triad2, triad3 ) =
            getChord model

        ( octave, triadNum ) =
            Array.get model.currPosition patternTable |> unsafeMaybe

        note =
            case triadNum of
                1 ->
                    triad1

                2 ->
                    triad2

                3 ->
                    triad3

                _ ->
                    Debug.crash "unexpected triad number"

        midiNote =
            48 + (octave * 12) + (noteToInt note)
    in
        midiNote


init : Model
init =
    { keysDown =
        Array.fromList [ 60, 64, 68 ]
        -- , tempo = 120.0
    , tempo = 480.0
    , currPosition = 0
    }



-- 0  1 2 3  | 4  5  6  7 |  8  9  10 11 | 12  13 14 15
-- 0  0 0 1    1  1  2  2   2  2   2   1   1   1   0  0
-- 1  2 3 1    2  3  1  2   3  2   1   3   2   1   3  2


patternTable : Array ( Int, Int )
patternTable =
    [ ( 0, 1 )
    , ( 0, 2 )
    , ( 0, 3 )
    , ( 1, 1 )
    , ( 1, 2 )
    , ( 1, 3 )
    , ( 2, 1 )
    , ( 2, 2 )
    , ( 2, 3 )
    , ( 2, 2 )
    , ( 2, 1 )
    , ( 1, 3 )
    , ( 1, 2 )
    , ( 1, 1 )
    , ( 0, 3 )
    , ( 0, 2 )
    ]
        |> Array.fromList



-- UPDATE


type Msg
    = Tick


update : Msg -> Model -> ( Model, Int )
update action model =
    case action of
        Tick ->
            let
                currPosition =
                    (model.currPosition + 1) % 16

                model =
                    { model | currPosition = currPosition }
            in
                ( model, getCurrentNote model )


getDurationMillis : Float -> Float
getDurationMillis tempo =
    (1.0 / tempo) * 60.0 * 1000.0


subscription : Model -> Sub Msg
subscription model =
    Time.every (Time.millisecond * (getDurationMillis model.tempo)) (\_ -> Tick)
