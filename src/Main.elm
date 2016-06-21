import Html.App
import FaustInstant exposing (Model, Msg, init, update, view)

main : Program Never
main =
  Html.App.program
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch FaustInstant.subscriptions
