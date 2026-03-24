! Copyright (C) 2024 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel locals math opengl sequences strings ui.render
ui.text unicode ;
IN: ui.text.chunked

CONSTANT: chunk-size 1000

: chunked-string? ( string -- ? )
    length chunk-size > ; inline

:: split-chunk ( string -- rest chunk )
    string length chunk-size > [
        string chunk-size string last-grapheme-from cut-slice :> ( chunk rest )
        rest chunk >string
    ] [
        "" string >string
    ] if ; inline

: string>chunks ( string -- chunks )
    [ dup empty? not ] [ split-chunk ] produce nip ;

: string-dim-chunked ( font string -- dim )
    string>chunks [ text-dim ] with map
    [ [ first ] map-sum ] [ [ second ] map maximum ] bi 2array ;

: draw-chunk ( font chunk -- )
    [ draw-text ] [ text-width 0.0 2array gl-translate ] 2bi ; inline

:: draw-string-chunked ( font string -- )
    [
        string string>chunks [| chunk |
            font chunk draw-chunk
        ] each
    ] with-matrix ;
