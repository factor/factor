USING: editors io.files io.launcher kernel math.parser
namespaces sequences windows.shell32 ;
IN: editors.notepadpp

: notepadpp-path
    \ notepadpp-path get-global [
        program-files "notepad++\\notepad++.exe" append-path
    ] unless* ;

: notepadpp ( file line -- )
    [
        notepadpp-path ,
        "-n" swap number>string append , ,
    ] { } make run-detached drop ;

[ notepadpp ] edit-hook set-global
