! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: editors io.pathnames io.standard-paths kernel make
math.parser namespaces sequences system ;
IN: editors.sublime

SINGLETON: sublime
sublime editor-class set-global

HOOK: find-sublime-path os ( -- path )

M: object find-sublime-path "sublime" ;

M: macosx find-sublime-path
    "com.sublimetext.2" find-native-bundle [
        "Contents/SharedSupport/bin/subl" append-path
    ] [
        f
    ] if* ;

ERROR: editor-not-found editor ;

: sublime-path  ( -- path )
    \ sublime-path get-global [
        find-sublime-path [ "sublime" editor-not-found ] unless*
    ] unless* ;

M: sublime editor-command ( file line -- command )
    [
        sublime-path , "-a" , number>string ":" glue ,
    ] { } make ;
