USING: editors io.files io.launcher io.standard-paths kernel
math.parser namespaces sequences make ;
IN: editors.ted-notepad

SINGLETON: ted-notepad

: ted-notepad-path ( -- path )
    \ ted-notepad-path get [
        { "TED Notepad" } "tednpad.exe" find-in-applications
        [ "TedNPad.exe" ] unless*
    ] unless* ;

M: ted-notepad editor-command
    [
        ted-notepad-path ,
        number>string "/l" prepend , ,
    ] { } make ;
