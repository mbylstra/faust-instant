module Components.SimpleDialog.Stylesheet exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Html.CssHelpers


type CssClasses
    = Backdrop
    | Modal



-- | Body


namespace_ : String
namespace_ =
    "mbylstra-simple-dialog-"


css : Stylesheet
css =
    (stylesheet << namespace namespace_)
        [ (.) Backdrop
            [ height (pct 100)
            , width (pct 100)
            , position fixed
            , property "z-index" "1000000"
            , top (px 0)
            , left (px 0)
            , backgroundColor (rgba 0 0 0 0.7)
              -- , animation: fadeIn 0.3s forwards;
            , property "opacity" "1.0"
            ]
        , (.) Modal
            [ position fixed
            , left (pct 50)
            , top (pct 50)
            , property "transform" "translate(-50%, -50%)"
            , property "max-height" "calc(100% - 100px)"
            ]
        ]


{ id, class, classList } =
    Html.CssHelpers.withNamespace namespace_
