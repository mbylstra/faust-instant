port module Stylesheets exposing (..)

import Css.File exposing (CssFileStructure, CssCompilerProgram)
import Components.SimpleDialog.Stylesheet as SimpleDialogStylesheet
import GridControl.DefaultCss

port files : CssFileStructure -> Cmd msg


fileStructure : CssFileStructure
fileStructure =
  Css.File.toFileStructure
    [ ( "main.css"
      , Css.File.compile
            [ SimpleDialogStylesheet.css
            , GridControl.DefaultCss.css
            ]
      )
    ]


main : CssCompilerProgram
main =
  Css.File.compiler files fileStructure
