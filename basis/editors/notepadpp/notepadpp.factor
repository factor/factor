USING: editors io.files io.launcher kernel math.parser
namespaces sequences io.directories.search.windows make ;
IN: editors.notepadpp

SINGLETON: notepadpp
notepadpp editor-class set-global

: notepadpp-path ( -- path )
    \ notepadpp-path get-global [
        "notepad++" [ "notepad++.exe" tail? ] find-in-program-files
        [ "notepad++.exe" ] unless*
    ] unless* ;

M: notepadpp editor-command ( file line -- command )
    [
        notepadpp-path ,
        number>string "-n" prepend , ,
    ] { } make ;
