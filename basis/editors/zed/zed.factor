USING: combinators.short-circuit editors io.pathnames io.standard-paths
kernel make math.parser namespaces sequences system ;
IN: editors.zed

SINGLETON: zed

HOOK: zed-path os ( -- path/f )

M: macos zed-path
    "dev.zed.Zed" find-native-bundle [
        "Contents/MacOS/cli" append-path
    ] [
        f
    ] if* ;

M: linux zed-path
    {
        [ \ zed-path get ]
        [ "zed" find-in-path ]
        [ "~/.local/bin/zed" absolute-path ]
    } 0|| ;

M: zed editor-command
    [ zed-path , number>string ":" glue , ] { } make ;
