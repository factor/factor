USING: editors io.standard-paths kernel make math.parser
namespaces ;
IN: editors.editplus

SINGLETON: editplus

: editplus-path ( -- path )
    \ editplus-path get [
        { "EditPlus 2" } "editplus.exe" find-in-applications
        [ "editplus.exe" ] unless*
    ] unless* ;

M: editplus editor-command
    [
        editplus-path , "-cursor" , number>string , ,
    ] { } make ;
