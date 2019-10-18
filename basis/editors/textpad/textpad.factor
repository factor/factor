USING: editors io.files io.launcher kernel math.parser
namespaces sequences make io.directories.search
io.directories.search.windows ;
IN: editors.textpad

: textpad-path ( -- path )
    \ textpad-path get-global [
        "TextPad 5" [ "TextPad.exe" tail? ] find-in-program-files
        [ "TextPad.exe" ] unless*
    ] unless* ;

: textpad ( file line -- )
    [
        textpad-path , [ , ] [ number>string "(" ",0)" surround , ] bi*
    ] { } make run-detached drop ;

[ textpad ] edit-hook set-global
