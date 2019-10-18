! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: editors io.launcher kernel make math.parser namespaces
sequences ;
IN: editors.gedit

SINGLETON: gedit
gedit editor-class set-global

: gedit-path ( -- path )
    \ gedit-path get-global [
        "gedit"
    ] unless* ;

M: gedit editor-command ( file line -- command )
    [
        gedit-path , number>string "+" prepend , ,
    ] { } make ;
