! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: editors.geany io.directories.search.windows kernel
namespaces sequences system ;
IN: editors.geany.windows

M: windows geany-path
    \ geany-path get-global [
        "Geany" [ "Geany.exe" tail? ] find-in-program-files
    ] unless* ;