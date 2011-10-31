USING: editors io.files io.launcher kernel math.parser
namespaces sequences windows.shell32 make
io.directories.search.windows ;
IN: editors.emeditor

SINGLETON: emeditor
emeditor editor-class set-global

: emeditor-path ( -- path )
    \ emeditor-path get-global [
        "EmEditor" [ "EmEditor.exe" tail? ] find-in-program-files
        [ "EmEditor.exe" ] unless*
    ] unless* ;

M: emeditor editor-command ( file line -- command )
    [
        emeditor-path , "/l" , number>string , ,
    ] { } make ;
