! Copyright (C) 2008 Kibleur Christophe.
! See http://factorcode.org/license.txt for BSD license.
USING: editors io.standard-paths kernel make math.parser
namespaces ;
IN: editors.etexteditor

SINGLETON: etexteditor

editor-class [ etexteditor ] initialize

: etexteditor-path ( -- str )
    \ etexteditor-path get [
        { "e" } "e.exe" find-in-applications
        [ "e.exe" ] unless*
    ] unless* ;

M: etexteditor editor-command
    [
        etexteditor-path ,
        [ , ] [ "--line" , number>string , ] bi*
    ] { } make ;
