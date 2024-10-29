! Copyright (C) 2024 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: editors io.pathnames io.standard-paths kernel make
math.parser namespaces sequences system ;
IN: editors.rider

SINGLETON: rider

HOOK: find-rider-path os ( -- path )

M: object find-rider-path f ;

M: macos find-rider-path
    "com.jetbrains.rider" find-native-bundle [
        "Contents/MacOS/rider" append-path
    ] [
        f
    ] if* ;

M: windows find-rider-path
    { "Jetbrains" } "rider64.exe" find-in-applications
    [ "rider64.exe" ] unless* ;

: rider-path  ( -- path )
    \ rider-path get [
        find-rider-path [ "rider" ?find-in-path ] unless*
    ] unless* ;

M: rider editor-command
    [ find-rider-path , "--line" , number>string , , ] { } make ;
