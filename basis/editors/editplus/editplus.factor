USING: editors io.files io.launcher kernel math.parser
namespaces sequences windows.shell32 make
io.directories.search.windows ;
IN: editors.editplus

: editplus-path ( -- path )
    \ editplus-path get-global [
        "EditPlus 2" [ "editplus.exe" tail? ] find-in-program-files
        [ "editplus.exe" ] unless*
    ] unless* ;

: editplus ( file line -- )
    [
        editplus-path , "-cursor" , number>string , ,
    ] { } make run-detached drop ;

[ editplus ] edit-hook set-global
