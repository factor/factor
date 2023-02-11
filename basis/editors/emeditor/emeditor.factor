USING: editors io.standard-paths kernel make math.parser
namespaces ;
IN: editors.emeditor

SINGLETON: emeditor

: emeditor-path ( -- path )
    \ emeditor-path get [
        { "EmEditor" } "emeditor.exe" find-in-applications
        [ "EmEditor.exe" ] unless*
    ] unless* ;

M: emeditor editor-command
    [
        emeditor-path , "/l" , number>string , ,
    ] { } make ;
