! Copyright (C) 2008 Kibleur Christophe.
! See http://factorcode.org/license.txt for BSD license.
USING: editors io.files io.launcher kernel math.parser make
namespaces sequences windows.shell32 io.directories.search.windows ;
IN: editors.etexteditor

SINGLETON: etexteditor
etexteditor editor-class set-global

: etexteditor-path ( -- str )
    \ etexteditor-path get-global [
        "e" [ "e.exe" tail? ] find-in-program-files
        [ "e" ] unless*
    ] unless* ;

M: etexteditor editor-command ( file line -- command )
    [
        etexteditor-path ,
        [ , ] [ "--line" , number>string , ] bi*
    ] { } make ;

