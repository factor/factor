! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit editors io.pathnames
io.standard-paths kernel make math.parser namespaces sequences
system ;
IN: editors.sublime

SINGLETON: sublime
sublime editor-class set-global

HOOK: find-sublime-path os ( -- path )

M: object find-sublime-path f ;

M: macosx find-sublime-path
    { "com.sublimetext.3" "com.sublimetext.2" } [ find-native-bundle ] map-find drop [
        "Contents/SharedSupport/bin/subl" append-path
    ] [
        f
    ] if* ;

M: windows find-sublime-path
    {
        [ { "Sublime Text 3" } "subl.exe" find-in-applications ]
        [ { "Sublime Text 2" } "sublime_text.exe" find-in-applications ]
        [ "subl.exe" ]
    } 0|| ;

: sublime-path  ( -- path )
    \ sublime-path get [
        find-sublime-path [ "subl" ?find-in-path ] unless*
    ] unless* ;

M: sublime editor-command ( file line -- command )
    [
        sublime-path , "-a" , number>string ":" glue ,
    ] { } make ;
