USING: editors io.files io.launcher kernel math.parser
namespaces sequences windows.shell32 make
io.directories.search.windows ;
IN: editors.editplus

SINGLETON: editplus
editplus editor-class set-global

: editplus-path ( -- path )
    \ editplus-path get-global [
        "EditPlus 2" [ "editplus.exe" tail? ] find-in-program-files
        [ "editplus.exe" ] unless*
    ] unless* ;

M: editplus editor-command ( file line -- command )
    [
        editplus-path , "-cursor" , number>string , ,
    ] { } make ;
