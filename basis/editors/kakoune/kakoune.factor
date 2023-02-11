USING: editors io.standard-paths kernel make math.parser
namespaces sequences strings ;
IN: editors.kakoune

SINGLETON: kakoune

SYMBOL: kak-path

HOOK: find-kak-path editor-class ( -- path )

M: kakoune find-kak-path "kak" ?find-in-path ;

: actual-kak-path ( -- path )
    \ kak-path get [ find-kak-path ] unless* ;

M: kakoune editor-command
    [
        actual-kak-path dup string? [ , ] [ % ] if
        number>string "+" prepend ,
        ,
    ] { } make  ;

M: kakoune editor-detached? t ;
