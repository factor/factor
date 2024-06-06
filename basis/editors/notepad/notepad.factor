! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays editors io.directories io.files io.pathnames
kernel namespaces sequences windows.shell32 ;

IN: editors.notepad

SINGLETON: notepad

: notepad-path ( -- path )
    \ notepad-path get [
        windows-directory "notepad.exe" append-path
        [ file-exists? ] verify
    ] unless* [
        windows-directory
        [ "notepad.exe" tail? ] find-file
    ] unless* ;

M: notepad editor-command
    drop [ notepad-path ] dip 2array ;
