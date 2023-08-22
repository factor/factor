! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: editors io.standard-paths kernel make math math.parser
namespaces sequences system ;
IN: editors.10x

SINGLETON: 10x-editor

SYMBOL: 10x-editor-path

HOOK: find-10x-editor-path os ( -- path )

M: unix find-10x-editor-path "10x" ?find-in-path ;

M: windows find-10x-editor-path
    { "PureDevSoftware/10x" } "10x.exe" find-in-applications
    [ "10x.exe" ] unless* ;

M: 10x-editor editor-command
    [
        10x-editor-path get [ find-10x-editor-path ] unless* ,
        [ , ]
        ! python command SetCursorPos
        [ 1 - number>string "N10X.Editor.SetCursorPos((0," "))" surround , ] bi*
    ] { } make ;
