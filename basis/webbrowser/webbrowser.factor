! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators combinators.short-circuit present sequences strings system
ui.operations urls vocabs ;

IN: webbrowser

HOOK: open-file os ( path -- )

{
    { [ os macosx?  ] [ "webbrowser.macosx"  ] }
    { [ os linux?   ] [ "webbrowser.linux"   ] }
    { [ os windows? ] [ "webbrowser.windows" ] }
} cond require

: open-url ( url -- )
    >url present open-file ;

[ url? ] \ open-url H{ } define-operation

PREDICATE: url-like < string
    { [ "http://" head? ] [ "https://" head? ] } 1|| ;

[ url-like? ] \ open-url H{ } define-operation
