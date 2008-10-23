! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types combinators kernel io.files unix.stat
math accessors system unix io.backend layouts vocabs.loader
sequences csv io.streams.string io.encodings.utf8 namespaces
unix.statfs io.files ;
IN: unix.statfs.linux

cell-bits {
    { 32 [ "unix.statfs.linux.32" require ] }
    { 64 [ "unix.statfs.linux.64" require ] }
} case

TUPLE: mtab-entry file-system-name mount-point type options
frequency pass-number ;

: mtab-csv>mtab-entry ( csv -- mtab-entry )
    [ mtab-entry new ] dip
    {
        [ first >>file-system-name ]
        [ second >>mount-point ]
        [ third >>type ]
        [ fourth <string-reader> csv first >>options ]
        [ 4 swap nth >>frequency ]
        [ 5 swap nth >>pass-number ]
    } cleave ;

: parse-mtab ( -- array )
    [
        "/etc/mtab" utf8 <file-reader>
        CHAR: \s delimiter set csv
    ] with-scope
    [ mtab-csv>mtab-entry ] map ;

M: linux mounted
    parse-mtab [
        mount-point>>
        [ file-system-info ] keep >>name
    ] map ;
