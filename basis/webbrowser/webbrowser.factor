! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: accessors command-line io.pathnames kernel namespaces
sequences strings system ui.operations urls vocabs vocabs.platforms ;
IN: webbrowser

HOOK: open-item os ( item -- )

USE-OS-SUFFIX: webbrowser

: open-url ( url -- )
    >url open-item ;

PREDICATE: url-string < string >url protocol>> >boolean ;

[ pathname? ] \ open-item H{ } define-operation
[ [ url? ] [ url-string? ] bi or ] \ open-url H{ } define-operation

: webbrowser-main ( -- )
    command-line get [ open-url ] each ;

MAIN: webbrowser-main
