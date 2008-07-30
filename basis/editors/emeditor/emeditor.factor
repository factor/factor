USING: editors hardware-info.windows io.files io.launcher
kernel math.parser namespaces sequences windows.shell32 ;
IN: editors.emeditor

: emeditor-path ( -- path )
    \ emeditor-path get-global [
        program-files "\\EmEditor\\EmEditor.exe" append-path
    ] unless* ;

: emeditor ( file line -- )
    [
        emeditor-path , "/l" , number>string , ,
    ] { } make run-detached drop ;

[ emeditor ] edit-hook set-global
