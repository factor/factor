! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators system ui.operations urls vocabs ;

IN: webbrowser

HOOK: open-file os ( path -- )

HOOK: open-url os ( url -- )

{
    { [ os macosx?  ] [ "webbrowser.macosx"  ] }
    { [ os linux?   ] [ "webbrowser.linux"   ] }
    { [ os windows? ] [ "webbrowser.windows" ] }
} cond require

[ url? ] \ open-url H{ } define-operation
