! Copyright (C) 2024 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: editors io.pathnames io.standard-paths kernel make system ;
IN: editors.notepadnext

SINGLETON: notepadnext

HOOK: find-notepadnext-path os ( -- path )

M: macosx find-notepadnext-path
    "com.yourcompany.NotepadNext" find-native-bundle [
        "Contents/MacOS/NotepadNext" append-path
    ] [
        f
    ] if* ;

M: windows find-notepadnext-path
    { "Notepad Next" } "NotepadNext.exe" find-in-applications
    [ "NotepadNext.exe" ] unless* ;

M: linux find-notepadnext-path
    "NotepadNext" find-in-path ;

M: notepadnext editor-command
    '[
        find-notepadnext-path ,
        _ ,
        _ drop ! "-n" , _ ,
    ] { } make ;
