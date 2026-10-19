! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors combinators.short-circuit command-line
io.pathnames kernel namespaces sequences strings system
urls vocabs vocabs.loader ;

IN: webbrowser

HOOK: open-item os ( item -- )

"webbrowser." os name>> append require

: open-url ( url -- )
    >url open-item ;

PREDICATE: url-string < string
    {
        [ "://" subseq-index ]
        [ >url protocol>> >boolean ]
    } 1&& ;

: webbrowser-main ( -- )
    command-line get [ open-url ] each ;

MAIN: webbrowser-main

{ "webbrowser" "ui.operations" } "webbrowser.ui" require-when
