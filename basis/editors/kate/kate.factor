USING: editors io.pathnames io.standard-paths kernel make
math.parser namespaces sequences system ;

IN: editors.kate

SINGLETON: kate

HOOK: find-kate-path os ( -- path )

M: object find-kate-path f ;

M: windows find-kate-path
    { "Kate" } "kate.exe" find-in-applications
    [ "kate.exe" ] unless* ;

M: macos find-kate-path
    "org.kde.Kate" find-native-bundle [
        "Contents/MacOS/kate" append-path
    ] [
        f
    ] if* ;

: kate-path ( -- path )
    \ kate-path get [
        find-kate-path [ "kate" ?find-in-path ] unless*
    ] unless* ;

M: kate editor-command
    [ kate-path , drop , ] { } make ;
