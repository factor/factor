! Copyright (C) 2007 Clemens F. Hofreither.
! See http://factorcode.org/license.txt for BSD license.
! clemens.hofreither@gmx.net
USING: io.files io.launcher kernel namespaces io.directories.search.windows
math math.parser editors sequences make unicode.case ;
IN: editors.scite

SINGLETON: scite
scite editor-class set-global

: scite-path ( -- path )
    \ scite-path get-global [
        "Scintilla Text Editor"
        [ >lower "scite.exe" tail? ] find-in-program-files

        [
            "SciTE Source Code Editor"
            [ >lower "scite.exe" tail? ] find-in-program-files
        ] unless*
        [ "scite.exe" ] unless*
    ] unless* ;

M: scite editor-command ( file line -- cmd )
    swap
    [
        scite-path ,
        ,
        number>string "-goto:" prepend ,
    ] { } make ;
