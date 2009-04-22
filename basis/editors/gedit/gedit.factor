! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: editors io.launcher kernel make math.parser namespaces
sequences ;
IN: editors.gedit

: gedit-path ( -- path )
    \ gedit-path get-global [
        "gedit"
    ] unless* ;

: gedit ( file line -- )
    [
        gedit-path , number>string "+" prepend , ,
    ] { } make run-detached drop ;

[ gedit ] edit-hook set-global
