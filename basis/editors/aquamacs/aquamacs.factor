! File: aquamacs.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2017 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: editors io.pathnames io.standard-paths kernel make
math.parser namespaces sequences system ;
IN: editors.aquamacs

SINGLETON: aquamacs

HOOK: find-aquamacs-path os ( -- path )

M: object find-aquamacs-path f ;

M: macos find-aquamacs-path
    "org.gnu.Aquamacs" find-native-bundle [
        "Contents/MacOS/bin/aquamacs" append-path
    ] [
        f
    ] if* ;

: aquamacs-path ( -- path )
    \ aquamacs-path get [
        find-aquamacs-path [ "aquamacs" ?find-in-path ] unless*
    ] unless* ;

M: aquamacs editor-command ( file line -- command )
    [ aquamacs-path , drop , ] { } make ;
