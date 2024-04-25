! Copyright (C) 2024 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: editors io.pathnames io.standard-paths kernel make sequences system ;
IN: editors.notepadnext

SINGLETON: notepadnext

HOOK: find-notepadnext-path os ( -- path line#? )

M: macosx find-notepadnext-path
    {
        "com.yourcompany.NotepadNext"
        "io.github.dail8859.NotepadNext"
    } [
        find-native-bundle [
            "Contents/MacOS/NotepadNext" append-path
        ] [
            f
        ] if*
    ] map-find "io.github.dail8859.NotepadNext" = ;

M: windows find-notepadnext-path
    { "Notepad Next" } "NotepadNext.exe" find-in-applications
    [ "NotepadNext.exe" ] unless* t ;

M: linux find-notepadnext-path
    "NotepadNext" find-in-path t ;

M: notepadnext editor-command
    '[
        find-notepadnext-path
        [ , _ , ] [ [ "-n" , _ , ] when ] bi*
    ] { } make ;
