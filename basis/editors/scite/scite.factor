! Copyright (C) 2007 Clemens F. Hofreither.
! See https://factorcode.org/license.txt for BSD license.
! clemens.hofreither@gmx.net
USING: editors io.standard-paths kernel make math.parser
namespaces sequences system ;
IN: editors.scite

SINGLETON: scite

SYMBOL: scite-path

HOOK: find-scite-path os ( -- path )

M: unix find-scite-path "scite" ?find-in-path ;

M: windows find-scite-path
    {
        "Scintilla Text Editor"
        "SciTE Source Code Editor"
    } "scite.exe" find-in-applications
    [ "scite.exe" ] unless* ;

M: scite editor-command
    swap
    [
        scite-path get [ find-scite-path ] unless* ,
        ,
        number>string "-goto:" prepend ,
    ] { } make ;
