USING: editors io.pathnames io.standard-paths kernel make
math.parser sequences ;
IN: editors.zed

SINGLETON: zed

: find-zed-bundle-path ( -- path/f )
    "dev.zed.Zed" find-native-bundle [
        "Contents/MacOS/cli" append-path
    ] [
        f
    ] if* ;

M: zed editor-command
    [ find-zed-bundle-path , number>string ":" glue , ] { } make ;
