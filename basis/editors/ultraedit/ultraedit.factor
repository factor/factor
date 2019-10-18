USING: editors io.files io.launcher kernel math.parser
namespaces sequences io.directories.search.windows make ;
IN: editors.ultraedit

: ultraedit-path ( -- path )
    \ ultraedit-path get-global [
        "IDM Computer Solutions" [ "uedit32.exe" tail? ] find-in-program-files
        [ "uedit32.exe" ] unless*
    ] unless* ;

: ultraedit ( file line -- )
    [
        ultraedit-path , [ swap % "/" % # "/1" % ] "" make ,
    ] { } make run-detached drop ;


[ ultraedit ] edit-hook set-global
