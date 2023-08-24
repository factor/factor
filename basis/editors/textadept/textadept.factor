! Copyright 2013 Michael T. Richter <ttmrichter@gmail.com>
!
! This program is free software and comes without any warranty, express nor
! implied.  It is, in short, warranted to do absolutely nothing but (possibly)
! occupy storage space.  You can redistribute it and/or modify it under the
! terms of the Do What The Fuck You Want To Public License, Version 2, as
! published by Sam Hocevar.  Consult http://www.wtfpl.net/txt/copying for full
! legal details.
!
! For more information about Textadept, consult http://foicica.com/textadept/

USING: combinators.short-circuit editors io.launcher
io.pathnames io.standard-paths kernel make math math.parser
namespaces sequences system vocabs ;
IN: editors.textadept

SINGLETON: textadept

HOOK: find-textadept-path os ( -- path )

M: object find-textadept-path f ;

M: macosx find-textadept-path
    "com.textadept" find-native-bundle [
        "Contents/MacOS/textadept" append-path
    ] [
        f
    ] if* ;

M: windows find-textadept-path
    { "textadept_6.5.win32" } "textadept.exe" find-in-applications
    [ "textadept.exe" ] unless* ;

: textadept-path  ( -- path )
    \ textadept-path get [
        find-textadept-path [ "textadept" ?find-in-path ] unless*
    ] unless* ;

M: textadept editor-command
    swap [
        textadept-path , "-f" , , "-e" ,
        1 - number>string "goto_line(" ")" surround ,
    ] { } make ;
