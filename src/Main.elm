import Html.App

import Main.Model
import Main.Update
import Main.View
import Main.Subscriptions
import Main.Types

main : Program Never
main =
  Html.App.program
    { init = Main.Model.init
    , update = Main.Update.update
    , view = Main.View.view
    , subscriptions = subscriptions
    }

subscriptions : Main.Types.Model -> Sub Main.Types.Msg
subscriptions model =
  Sub.batch (Main.Subscriptions.subscriptions model)
