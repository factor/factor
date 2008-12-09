USING: editors io.files io.launcher kernel math.parser
namespaces sequences io.paths.windows make ;
IN: editors.ted-notepad

: ted-notepad-path ( -- path )
    \ ted-notepad-path get-global [
        "TED Notepad" t [ "TedNPad.exe" tail? ] find-in-program-files
    ] unless* ;

: ted-notepad ( file line -- )
    [
        ted-notepad-path ,
        number>string "/l" prepend , ,
    ] { } make run-detached drop ;

[ ted-notepad ] edit-hook set-global
