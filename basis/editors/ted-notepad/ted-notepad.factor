USING: editors io.files io.launcher kernel math.parser
namespaces sequences io.directories.search.windows make ;
IN: editors.ted-notepad

SINGLETON: ted-notepad
ted-notepad editor-class set-global

: ted-notepad-path ( -- path )
    \ ted-notepad-path get-global [
        "TED Notepad" [ "TedNPad.exe" tail? ] find-in-program-files
        [ "TedNPad.exe" ] unless*
    ] unless* ;

M: ted-notepad editor-command ( file line -- command )
    [
        ted-notepad-path ,
        number>string "/l" prepend , ,
    ] { } make ;
