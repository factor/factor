USING: editors io.standard-paths kernel make math.parser
namespaces ;
IN: editors.ultraedit

SINGLETON: ultraedit
ultraedit editor-class set-global

: ultraedit-path ( -- path )
    \ ultraedit-path get-global [
        { "IDM Computer Solutions" } "uedit32.exe" find-in-applications
        [ "uedit32.exe" ] unless*
    ] unless* ;

M: ultraedit editor-command ( file line -- command )
    [
        ultraedit-path , [ swap % "/" % # "/1" % ] "" make ,
    ] { } make ;
