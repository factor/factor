! Copyright 2013 Michael T. Richter <ttmrichter@gmail.com>
!
! This program is free software and comes without any warranty, express nor
! implied.  It is, in short, warranted to do absolutely nothing but (possibly)
! occupy storage space.  You can redistribute it and/or modify it under the
! terms of the Do What The Fuck You Want To Public License, Version 2, as
! published by Sam Hocevar.  Consult http://www.wtfpl.net/txt/copying for full
! legal details.
!
! For this code to work, the following code needs to be added to the textadept
! "init.lua" file:
!
! function my_goto_line(line)
!     _G.buffer:goto_line(line - 1)
! end
! args.register('-J', '--JUMP', 1, my_goto_line, 'Jump to line')
!
! For more information about Textadept, consult http://foicica.com/textadept/

USING: editors io.launcher io.pathnames io.standard-paths kernel
make math math.parser namespaces sequences system ;

IN: editors.textadept

SINGLETON: textadept
textadept editor-class set-global

HOOK: find-textadept-path os ( -- path )

M: object find-textadept-path "textadept" ;

M: macosx find-textadept-path
    "com.textadept" find-native-bundle [
        "Contents/MacOS/textadept" append-path
    ] [
        f
    ] if* ;

! M: windows find-textadept-path
!     let-Windows-users-fill-this-in
!     ;

: textadept-path  ( -- path )
    \ textadept-path get-global [
        find-textadept-path "textadept" or
    ] unless* ;

M: textadept editor-command ( file line -- command )
    swap [
        textadept-path , "-f" , , "-J" , number>string ,
    ] { } make ;
