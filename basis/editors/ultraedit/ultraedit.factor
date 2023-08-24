USING: editors io.pathnames io.standard-paths kernel make
math.parser namespaces system ;
IN: editors.ultraedit

SINGLETON: ultraedit

HOOK: find-ultraedit os ( -- path )

M: windows find-ultraedit
    { "IDM Computer Solutions" } "uedit32.exe" find-in-applications
    [ "uedit32.exe" ] unless* ;

M: macosx find-ultraedit
    "com.idmcomp.uex" find-native-bundle [
        "Contents/MacOS/UltraEdit" append-path
    ] [
        f
    ] if* ;

: ultraedit-path ( -- path )
    \ ultraedit-path get-global [ find-ultraedit ] unless* ;

M: ultraedit editor-command
    [
        ultraedit-path ,
        os windows? [
            [ swap % "/" % # "/1" % ] "" make
        ] [ drop ] if ,
    ] { } make ;
