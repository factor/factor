USING: editors io.pathnames io.standard-paths kernel make
math.parser namespaces sequences system ;

IN: editors.lapce

SINGLETON: lapce

editor-class [ lapce ] initialize

HOOK: find-lapce-path os ( -- path )

M: object find-lapce-path f ;

M: macosx find-lapce-path
    "io.lapce" find-native-bundle [
        "Contents/MacOS/lapce" append-path
    ] [
        f
    ] if* ;

: lapce-path ( -- path )
    \ lapce-path get [
        find-lapce-path [ "lapce" ?find-in-path ] unless*
    ] unless* ;

M: lapce editor-command
    [ lapce-path , drop , ] { } make ;
