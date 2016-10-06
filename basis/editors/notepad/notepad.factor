! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays editors io.directories.search kernel namespaces
sequences windows.shell32 ;

IN: editors.notepad

SINGLETON: notepad
notepad editor-class set-global

: notepad-path ( -- path )
    \ notepad-path get [
        windows-directory t
        [ "notepad.exe" tail? ] find-file
    ] unless* ;

M: notepad editor-command ( file line -- command )
    drop [ notepad-path ] dip 2array ;
