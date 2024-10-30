! Copyright (C) 2024 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators combinators.short-circuit editors
generalizations io.files io.pathnames io.standard-paths kernel
make math.parser namespaces sequences system tools.which ;
IN: editors.cursor

SINGLETON: cursor

: find-cursor-path ( -- path )
    os {
        { linux [
            {
                [ "cursor" which ]
                [ "/usr/local/bin/cursor" ]
            } [ [ file-exists? ] 1guard ] map-compose 0|| ] }
        { macos [
            "com.todesktop.230313mzl4w4u92" find-native-bundle
            [ "Contents/MacOS/Cursor" append-path ] [ f ] if* ] }
        { windows [ "cursor.cmd" ] }
    } case ;

: cursor-invocation ( -- path )
    {
        [ \ cursor-invocation get ]
        [ find-cursor-path ]
        [ "cursor" ]
    } 0|| ;

ERROR: can't-find-cursor ;

: cursor-command ( file line -- seq )
    [
        cursor-invocation
        [ , ] [ can't-find-cursor ] if*
        "-g" , "-r" ,
        ! no command-line support yet
        ! see https://github.com/getcursor/cursor/issues/1858
        ! number>string ":" glue ,
        drop ,
    ] { } make ;

M: cursor editor-command
    cursor-command ;
