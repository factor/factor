USING: editors io.files io.launcher kernel math.parser
namespaces sequences windows.shell32 make io.paths.windows ;
IN: editors.editplus

: editplus-path ( -- path )
    \ editplus-path get-global [
        "EditPlus 2" t [ "editplus.exe" tail? ] find-in-program-files
    ] unless* ;

: editplus ( file line -- )
    [
        editplus-path , "-cursor" , number>string , ,
    ] { } make run-detached drop ;

[ editplus ] edit-hook set-global
