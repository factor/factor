! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors io.pathnames kernel sequences strings system
ui.operations urls vocabs ;

IN: webbrowser

HOOK: open-file os ( path -- )

"webbrowser." os name>> append require

: open-url ( url -- )
    >url open-file ;

[ pathname? ] \ open-file H{ } define-operation

[ url? ] \ open-url H{ } define-operation

PREDICATE: url-string < string >url protocol>> >boolean ;

[ url-string? ] \ open-url H{ } define-operation
