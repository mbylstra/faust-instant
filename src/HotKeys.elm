module HotKeys exposing (..)

import Keyboard.Extra as Keyboard


type Msg
    = KeyboardMsg Keyboard.Msg


type alias Model =
    { keyboardModel : Keyboard.Model
    , controlShiftPressed : Bool
    , keyList : List Keyboard.Key
    }


init : ( Model, Cmd Msg )
init =
    let
        ( keyboardModel, keyboardCmd ) =
            Keyboard.init
    in
        ( { keyboardModel  = keyboardModel
          , controlShiftPressed = False
          , keyList = []
          }
        , Cmd.map KeyboardMsg keyboardCmd
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyboardMsg keyMsg ->
            let
                ( keyboardModel, keyboardCmd ) =
                    Keyboard.update keyMsg model.keyboardModel
                controlShiftPressed =
                  Keyboard.isPressed Keyboard.Control keyboardModel
                  && Keyboard.isPressed Keyboard.Enter keyboardModel
            in
                ( { model
                    | keyboardModel = keyboardModel
                    , controlShiftPressed = controlShiftPressed
                    , keyList = Keyboard.pressedDown keyboardModel
                  }
                , Cmd.map KeyboardMsg keyboardCmd
                )

subscription : Sub Msg
subscription = Sub.map KeyboardMsg Keyboard.subscriptions
