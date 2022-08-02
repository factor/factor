! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays editors io.directories io.files io.pathnames
kernel namespaces sequences windows.shell32 ;

IN: editors.notepad

SINGLETON: notepad

editor-class [ notepad ] initialize

: notepad-path ( -- path )
    \ notepad-path get [
        windows-directory "notepad.exe" append-path
        dup file-exists? [ drop f ] unless
    ] unless* [
        windows-directory
        [ "notepad.exe" tail? ] find-file
    ] unless* ;

M: notepad editor-command
    drop [ notepad-path ] dip 2array ;
