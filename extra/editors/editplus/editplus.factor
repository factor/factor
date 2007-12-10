USING: editors io.files io.launcher kernel math.parser
namespaces sequences windows.shell32 ;
IN: editors.editplus

: editplus-path ( -- path )
    \ editplus-path get-global [
        program-files "\\EditPlus 2\\editplus.exe" append
    ] unless* ;

: editplus ( file line -- )
    [
        editplus-path % " -cursor " % # " " % %
    ] "" make run-detached ;

[ editplus ] edit-hook set-global
