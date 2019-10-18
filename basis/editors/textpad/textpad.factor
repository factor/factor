USING: editors io.files io.launcher kernel math.parser
namespaces sequences make io.directories.search
io.directories.search.windows ;
IN: editors.textpad

SINGLETON: textpad
textpad editor-class set-global

: textpad-path ( -- path )
    \ textpad-path get-global [
        "TextPad 5" [ "TextPad.exe" tail? ] find-in-program-files
        [ "TextPad.exe" ] unless*
    ] unless* ;

M: textpad editor-command ( file line -- command )
    [
        textpad-path , [ , ] [ number>string "(" ",0)" surround , ] bi*
    ] { } make ;
