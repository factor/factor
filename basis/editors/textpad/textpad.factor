USING: editors io.standard-paths kernel make math.parser
namespaces sequences ;
IN: editors.textpad

SINGLETON: textpad

: textpad-path ( -- path )
    \ textpad-path get-global [
        { "TextPad 5" } "textpad.exe" find-in-applications
        [ "TextPad.exe" ] unless*
    ] unless* ;

M: textpad editor-command
    [
        textpad-path ,
        [ , ] [ number>string "(" ",0)" surround , ] bi*
    ] { } make ;
