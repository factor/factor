USING: editors io.files io.launcher kernel math.parser
namespaces sequences io.directories.search.windows make ;
IN: editors.ultraedit

SINGLETON: ultraedit
ultraedit editor-class set-global

: ultraedit-path ( -- path )
    \ ultraedit-path get-global [
        "IDM Computer Solutions" [ "uedit32.exe" tail? ] find-in-program-files
        [ "uedit32.exe" ] unless*
    ] unless* ;

M: ultraedit editor-command ( file line -- command )
    [
        ultraedit-path , [ swap % "/" % # "/1" % ] "" make ,
    ] { } make ;
