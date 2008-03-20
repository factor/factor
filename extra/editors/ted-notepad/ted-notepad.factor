USING: editors io.files io.launcher kernel math.parser
namespaces sequences windows.shell32 ;
IN: editors.ted-notepad

: ted-notepad-path
    \ ted-notepad-path get-global [
        program-files "\\TED Notepad\\TedNPad.exe" append-path
    ] unless* ;

: ted-notepad ( file line -- )
    [
        ted-notepad-path , "/l" swap number>string append , ,
    ] { } make run-detached drop ;

[ ted-notepad ] edit-hook set-global
