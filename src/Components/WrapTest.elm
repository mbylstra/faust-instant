module Components.WrapTest exposing (Model, init, update, view)

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
import Html.App as App


-- MODEL


type alias Model =
    { prop1 : String
    , prop2 : Int
    }


init : Model
init =
    { prop1 = "hello"
    , prop2 = 2
    }



-- UPDATE


type Msg childMsg
    = M1
    | M2
    | M3
    | ChildMsg childMsg


update : Msg childMsg -> Model -> ( Model, Maybe childMsg )
update action model =
    case action of
        M1 ->
            ( { model | prop2 = 1 }, Nothing )

        M2 ->
            ( { model | prop2 = 2 }, Nothing )

        M3 ->
            ( { model | prop2 = 3 }, Nothing )

        ChildMsg childMsg ->
            ( model, Just childMsg )



-- VIEW


view : Model -> Html childMsg -> Html (Msg childMsg)
view model childHtml =
    div []
        [ button [ onClick M1 ] [ text "M1" ]
        , childHtml |> App.map ChildMsg
        ]
