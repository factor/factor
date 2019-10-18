USING: editors io.files io.launcher kernel math.parser
namespaces sequences io.directories.search.windows make ;
IN: editors.notepadpp

: notepadpp-path ( -- path )
    \ notepadpp-path get-global [
        "notepad++" [ "notepad++.exe" tail? ] find-in-program-files
        [ "notepad++.exe" ] unless*
    ] unless* ;

: notepadpp ( file line -- )
    [
        notepadpp-path ,
        "-n" swap number>string append , ,
    ] { } make run-detached drop ;

[ notepadpp ] edit-hook set-global
