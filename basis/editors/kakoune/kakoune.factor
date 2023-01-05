USING: editors io.standard-paths kernel make math.parser
namespaces sequences strings ;
IN: editors.kakoune

SINGLETON: kakoune

MIXIN: kak-base

INSTANCE: kakoune kak-base

editor-class [ kakoune ] initialize

SYMBOL: kak-path

HOOK: find-kak-path editor-class ( -- path )

M: kak-base find-kak-path "kak" ?find-in-path ;

: actual-kak-path ( -- path )
    \ kak-path get [ find-kak-path ] unless* ;

M: kak-base editor-command
    [
        actual-kak-path dup string? [ , ] [ % ] if
        number>string "+" prepend ,
        ,
    ] { } make  ;

M: kak-base editor-detached? t ;
