port module Components.MeasureText exposing (view)


import Html exposing
  -- delete what you don't need
  ( Html, div, span, img, p, a, h1, h2, h3, h4, h5, h6, h6, text
  , ol, ul, li, dl, dt, dd
  , form, input, textarea, button, select, option
  , table, caption, tbody, thead, tr, td, th
  , em, strong, blockquote, hr
  )
import Html.Attributes exposing
  ( style, class, id, title, hidden, type', checked, placeholder, selected
  , name, href, target, src, height, width, alt
  )


-- VIEW

view : Html msg
view =
  div
    [ style
      [ ("position", "absolute")
      , ("bottom", "100000px")
      , ("right", "100000px")
      , ("width", "5000px")
      ]
    ]
    [ div
      [ id "measure-text"
      , class "measure-text"
      , style
        [ ("display", "inline")
        , ("color", "black")
        , ("background-color", "pink")
        ]
      ]
      [ ]
    ]
