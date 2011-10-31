! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: editors io.launcher kernel io.directories.search.windows
math.parser namespaces sequences io.files arrays windows.shell32
io.directories.search ;
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
