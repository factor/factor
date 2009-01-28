USING: editors io.files io.launcher kernel math.parser
namespaces sequences windows.shell32 make io.paths.windows ;
IN: editors.emeditor

: emeditor-path ( -- path )
    \ emeditor-path get-global [
        "EmEditor" t [ "EmEditor.exe" tail? ] find-in-program-files
    ] unless* ;

: emeditor ( file line -- )
    [
        emeditor-path , "/l" , number>string , ,
    ] { } make run-detached drop ;

[ emeditor ] edit-hook set-global
