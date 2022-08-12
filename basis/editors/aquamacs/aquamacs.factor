! File: aquamacs.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2017 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: combinators.short-circuit editors io.standard-paths
kernel make math.parser namespaces sequences system ;
IN: editors.aquamacs

SINGLETON: aquamacs
aquamacs editor-class set-global

HOOK: find-aquamacs os ( -- path )

M: object find-aquamacs ( -- path )
    "aquamacs" ?find-in-path ;

M: aquamacs editor-command ( file line -- command )
    drop
    [
        "/Applications/Aquamacs.app/Contents/MacOS/bin/aquamacs" ,
        ,
    ] { } make
    ;

