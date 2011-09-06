! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types classes.struct kernel memory
tools.memory system vm ;
IN: tools.time.struct

STRUCT: benchmark-data
    { time ulonglong }
    { data-room data-heap-room }
    { code-room mark-sweep-sizes } ;

STRUCT: benchmark-data-pair
    { start benchmark-data }
    { stop benchmark-data } ;

: <benchmark-data> ( -- benchmark-data )
    \ benchmark-data <struct>
        nano-count >>time
        code-room >>code-room
        data-room >>data-room ; inline

: <benchmark-data-pair> ( start stop -- benchmark-data-pair )
    \ benchmark-data-pair <struct>
        swap >>stop
        swap >>start ; inline

: with-benchmarking ( ... quot -- ... benchmark-data-pair )
    <benchmark-data>
    [ call ] dip
    <benchmark-data> <benchmark-data-pair> ; inline

