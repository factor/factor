! Copyright (C) 2008 Kibleur Christophe.
! See http://factorcode.org/license.txt for BSD license.
USING: editors io.files io.launcher kernel math.parser make
namespaces sequences windows.shell32 io.directories.search.windows ;
IN: editors.etexteditor

: etexteditor-path ( -- str )
    \ etexteditor-path get-global [
        "e" [ "e.exe" tail? ] find-in-program-files
        [ "e" ] unless*
    ] unless* ;

: etexteditor ( file line -- )
    [
        etexteditor-path ,
        [ , ] [ "--line" , number>string , ] bi*
    ] { } make run-detached drop ;

[ etexteditor ] edit-hook set-global
