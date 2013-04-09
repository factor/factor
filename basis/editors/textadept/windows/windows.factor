! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: editors.textadept io.directories.search.windows
sequences system ;
IN: editors.textadept.windows

M: windows find-textadept-path
    "textadept_6.5.win32"
    [ "textadept.exe" tail? ] find-in-program-files ;
