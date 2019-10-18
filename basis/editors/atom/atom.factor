! Copyright (C) 2014 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: editors io.pathnames io.standard-paths kernel make
math.parser namespaces sequences system ;
IN: editors.atom

SINGLETON: atom-editor
atom-editor editor-class set-global

SYMBOL: atom-path

HOOK: find-atom os ( -- path )

M: object find-atom
    "atom" ?find-in-path ;

M: macosx find-atom
    "com.github.Atom" find-native-bundle [
        "Contents/MacOS/Atom" append-path
    ] [
        f
    ] if* ;

M: atom-editor editor-command ( file line -- command )
    [
        atom-path get [ find-atom ] unless* ,
        number>string ":" glue ,
    ] { } make ;
