USING: arrays assocs cocoa.plists combinators.short-circuit
editors io.pathnames io.standard-paths kernel make math.order
math.parser namespaces sequences splitting system ;
IN: editors.focus

SINGLETON: focus

HOOK: focus-path os ( -- path )

M: windows focus-path
    {
        [ \ focus-path get ]
        [ "focus.exe" ]
    } 0|| ;

M: linux focus-path
    {
        [ \ focus-path get ]
        [ "focus-linux" find-in-path ]
        [ "~/.local/bin/focus-linux" absolute-path ]
    } 0|| ;

MEMO: supports-open-to-line? ( -- ? )
    "dev.focus-editor" find-native-bundle [
        "Contents/Info.plist" append-path read-plist
        "CFBundleVersion" of "." split [ string>number ] map
        { 0 3 7 } after?
    ] [ f ] if* ;

M: focus editor-command
    os macos? [
        supports-open-to-line?
        [ number>string ":" glue ] [ drop ] if
        [ "open" , "-a" , "Focus" , , ] { } make
    ] [
        focus-path nip swap 2array
    ] if ;
