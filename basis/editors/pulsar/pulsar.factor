! Copyright (C) 2023 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
USING: editors io.pathnames io.standard-paths kernel make
math.parser namespaces sequences system ;
IN: editors.pulsar

SINGLETON: pulsar

SYMBOL: pulsar-path

HOOK: find-pulsar os ( -- path )

M: object find-pulsar
    "pulsar" ?find-in-path ;

M: macosx find-pulsar
    "dev.pulsar-edit.pulsar" find-native-bundle [
        "Contents/MacOS/Pulsar" append-path
    ] [
        f
    ] if* ;

M: pulsar editor-command
    [
        pulsar-path get [ find-pulsar ] unless* ,
        number>string ":" glue ,
    ] { } make ;
