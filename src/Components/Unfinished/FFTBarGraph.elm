module FFTBarGraph exposing (view)

import Html
    exposing
        -- delete what you don't need
        ( Html
        , div
        , span
        , img
        , p
        , a
        , h1
        , h2
        , h3
        , h4
        , h5
        , h6
        , h6
        , text
        , ol
        , ul
        , li
        , dl
        , dt
        , dd
        , form
        , input
        , textarea
        , button
        , select
        , option
        , table
        , caption
        , tbody
        , thead
        , tr
        , td
        , th
        , em
        , strong
        , blockquote
        , hr
        )
import Html.Attributes
    exposing
        ( style
        , class
        , id
        , title
        , hidden
        , type_
        , checked
        , placeholder
        , selected
        , name
        , href
        , target
        , src
        , height
        , width
        , alt
        )
import Html.Events
    exposing
        ( on
        , targetValue
        , targetChecked
        , keyCode
        , onBlur
        , onFocus
        , onSubmit
        , onClick
        , onDoubleClick
        , onMouseDown
        , onMouseUp
        , onMouseEnter
        , onMouseLeave
        , onMouseOver
        , onMouseOut
        )


view : List Float -> Html msg
view values =
    let
        bar i value =
            let
                valueNormalised =
                    (value + 50.0) / 50.0

                cssHeight =
                    if value < 1.0 then
                        toString (round (valueNormalised * 100.0)) ++ "%"
                    else
                        "100%"

                left =
                    toString (i * 1) ++ "px"
            in
                div
                    [ class "fft-bar-graph-bar"
                    , style [ ( "height", cssHeight ), ( "left", left ) ]
                    ]
                    []
    in
        div
            [ class "fft-bar-graph" ]
            (List.indexedMap bar values)
