! Copyright (C) 2008 Kibleur Christophe.
! See http://factorcode.org/license.txt for BSD license.
USING: editors io.files io.launcher kernel math.parser
namespaces sequences windows.shell32 make ;
IN: editors.etexteditor

: etexteditor-path ( -- str )
    \ etexteditor-path get-global [
        program-files "e\\e.exe" append-path
    ] unless* ;

: etexteditor ( file line -- )
    [
        etexteditor-path ,
        "-n" swap number>string append , ,
    ] { } make run-detached drop ;

[ etexteditor ] edit-hook set-global
