! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit editors io.pathnames
io.standard-paths kernel make math.parser namespaces sequences
system ;
IN: editors.jedit

SINGLETON: jedit
jedit editor-class set-global

ERROR: jedit-not-found ;

HOOK: find-jedit-path os ( -- path )

M: object find-jedit-path f ;

M: macosx find-jedit-path
    "org.gjt.sp.jedit" find-native-bundle
    dup [ "Contents/MacOS/jedit" append-path ] when ;

M: windows find-jedit-path
    { "jedit" } "jedit.exe" find-in-applications ;
    
: jedit-path ( -- path )
    \ jedit-path get-global [
        find-jedit-path "jedit" or
    ] unless* ;

M: jedit editor-command ( file line -- command/f )
    [
        find-jedit-path ,
        [ , ] [ number>string "+line:" prepend , ] bi*
    ] { } make ;
