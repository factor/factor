USING: editors io.files io.launcher kernel math.parser
namespaces sequences windows.shell32 make
io.directories.search.windows ;
IN: editors.emeditor

: emeditor-path ( -- path )
    \ emeditor-path get-global [
        "EmEditor" [ "EmEditor.exe" tail? ] find-in-program-files
        [ "EmEditor.exe" ] unless*
    ] unless* ;

: emeditor ( file line -- )
    [
        emeditor-path , "/l" , number>string , ,
    ] { } make run-detached drop ;

[ emeditor ] edit-hook set-global
