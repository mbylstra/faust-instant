module FileReader exposing (Model, Msg, init, update, view)

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
import Json.Decode


-- MODEL


type alias Model =
    { fileContents : Maybe String
    }



-- init : (Model, Cmd Msg)


init : Model
init =
    { fileContents = Nothing
    }



-- !
-- []
-- UPDATE


type Msg
    = FileChanged String



-- | M2
-- | M3


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action
        FileChanged s ->
            model ! []



-- VIEW
-- view : Model -> Html Msg


view : Model -> Html Msg
view model =
    input
        [ type_ "file"
        , onFileInputChange
        ]
        []



-- evt.target.files;


onFileInputChange : Html.Attribute Msg
onFileInputChange =
    on "change" (Json.Decode.map FileChanged sneakyFilesDecoder)



-- we can get the on change event and get the target, but then we need to
-- `decode` the .files object. Is this possible? Can we do something like decode
-- it as a string, pass it through a port (in disguise?)
-- how do we do this?
-- perhaps we generate a UUID, to make it easy for the JS to look up
-- the file and do the event handling?
-- but how would be deregister event listeners?
-- <input type="file" id="files" name="files[]" multiple />
-- <output id="list"></output>
--
-- <script>
--   function handleFileSelect(evt) {
--     var files = evt.target.files; // FileList object
--
--     // files is a FileList of File objects. List some properties.
--     var output = [];
--     for (var i = 0, f; f = files[i]; i++) {
--       output.push('<li><strong>', escape(f.name), '</strong> (', f.type || 'n/a', ') - ',
--                   f.size, ' bytes, last modified: ',
--                   f.lastModifiedDate ? f.lastModifiedDate.toLocaleDateString() : 'n/a',
--                   '</li>');
--     }
--     document.getElementById('list').innerHTML = '<ul>' + output.join('') + '</ul>';
--   }
--
--   document.getElementById('files').addEventListener('change', handleFileSelect, false);
-- </script>
-- elm-package install --yes circuithub/elm-json-extra
-- import Json.Decode.Extra exposing ((|:))
-- type alias Something =
--     { levelA : SomethingLevelA
--     }
--
-- type alias SomethingLevelA =
--     { levelB : String
--     }
--
-- decodeSomething : Json.Decode.Decoder Something
-- decodeSomething =
--     Json.Decode.succeed Something
--         |: ("levelA" := decodeSomethingLevelA)
--
-- decodeSomethingLevelA : Json.Decode.Decoder SomethingLevelA
-- decodeSomethingLevelA =
--     Json.Decode.succeed SomethingLevelA
--         |: ("levelB" := Json.Decode.string)


sneakyFilesDecoder : Json.Decode.Decoder String
sneakyFilesDecoder =
    Json.Decode.at [ "target", "files" ] Json.Decode.string
