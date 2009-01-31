! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: editors io.launcher kernel io.directories.search.windows
math.parser namespaces sequences io.files arrays windows.shell32
io.directories.search ;
IN: editors.notepad

: notepad-path ( -- path )
    \ notepad-path get [
        windows-directory t
        [ "notepad.exe" tail? ] find-file
    ] unless* ;

: notepad ( file line -- )
    drop notepad-path swap 2array run-detached drop ;

[ notepad ] edit-hook set-global

