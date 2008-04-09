USING: editors io.files io.launcher kernel math.parser
namespaces sequences windows.shell32 ;
IN: editors.ultraedit

: ultraedit-path ( -- path )
    \ ultraedit-path get-global [
        program-files
        "IDM Computer Solutions\\UltraEdit-32\\uedit32.exe" append-path
    ] unless* ;

: ultraedit ( file line -- )
    [
        ultraedit-path , [ swap % "/" % # "/1" % ] "" make ,
    ] { } make run-detached drop ;


[ ultraedit ] edit-hook set-global
