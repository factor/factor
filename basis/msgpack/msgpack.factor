! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: arrays assocs byte-arrays combinators endian grouping
hashtables io io.encodings io.encodings.binary
io.encodings.string io.encodings.utf8 io.streams.byte-array
io.streams.string kernel math math.bitwise math.order namespaces
sequences strings ;

IN: msgpack

DEFER: read-msgpack

<PRIVATE

: read-array ( n -- obj )
    [ read-msgpack ] replicate ;

: read-map ( n -- obj )
    2 * read-array 2 group >hashtable ;

: read-ext ( n -- obj )
    read be> [ 1 read signed-be> ] dip read 2array ;

PRIVATE>

SINGLETON: +msgpack-nil+

ERROR: unknown-format n ;

: read-msgpack ( -- obj )
    read1 {
        { [ dup 0xc0 = ] [ drop +msgpack-nil+ ] }
        { [ dup 0xc2 = ] [ drop f ] }
        { [ dup 0xc3 = ] [ drop t ] }
        { [ dup 0x00 0x7f between? ] [ ] }
        { [ dup 0xe0 mask? ] [ 1array signed-be> ] }
        { [ dup 0xcc = ] [ drop read1 ] }
        { [ dup 0xcd = ] [ drop 2 read be> ] }
        { [ dup 0xce = ] [ drop 4 read be> ] }
        { [ dup 0xcf = ] [ drop 8 read be> ] }
        { [ dup 0xd0 = ] [ drop 1 read signed-be> ] }
        { [ dup 0xd1 = ] [ drop 2 read signed-be> ] }
        { [ dup 0xd2 = ] [ drop 4 read signed-be> ] }
        { [ dup 0xd3 = ] [ drop 8 read signed-be> ] }
        { [ dup 0xca = ] [ drop 4 read be> bits>float ] }
        { [ dup 0xcb = ] [ drop 8 read be> bits>double ] }
        { [ dup 0xe0 mask 0xa0 = ] [ 0x1f mask read utf8 decode ] }
        { [ dup 0xd9 = ] [ drop read1 read utf8 decode ] }
        { [ dup 0xda = ] [ drop 2 read be> read utf8 decode ] }
        { [ dup 0xdb = ] [ drop 4 read be> read utf8 decode ] }
        { [ dup 0xc4 = ] [ drop read1 read B{ } like ] }
        { [ dup 0xc5 = ] [ drop 2 read be> read B{ } like ] }
        { [ dup 0xc6 = ] [ drop 4 read be> read B{ } like ] }
        { [ dup 0xf0 mask 0x90 = ] [ 0x0f mask read-array ] }
        { [ dup 0xdc = ] [ drop 2 read be> read-array ] }
        { [ dup 0xdd = ] [ drop 4 read be> read-array ] }
        { [ dup 0xf0 mask 0x80 = ] [ 0x0f mask read-map ] }
        { [ dup 0xde = ] [ drop 2 read be> read-map ] }
        { [ dup 0xdf = ] [ drop 4 read be> read-map ] }
        { [ dup 0xd4 = ] [ drop 1 read-ext ] }
        { [ dup 0xd5 = ] [ drop 2 read-ext ] }
        { [ dup 0xd6 = ] [ drop 4 read-ext ] }
        { [ dup 0xd7 = ] [ drop 8 read-ext ] }
        { [ dup 0xd8 = ] [ drop 16 read-ext ] }
        { [ dup 0xc7 = ] [ drop read1 read-ext ] }
        { [ dup 0xc8 = ] [ drop 2 read be> read-ext ] }
        { [ dup 0xc9 = ] [ drop 4 read be> read-ext ] }
        [ unknown-format ]
    } cond ;

ERROR: cannot-convert obj ;

GENERIC: write-msgpack ( obj -- )

<PRIVATE

M: +msgpack-nil+ write-msgpack drop 0xc0 write1 ;

M: f write-msgpack drop 0xc2 write1 ;

M: t write-msgpack drop 0xc3 write1 ;

M: integer write-msgpack
    dup 0 >= [
        {
            { [ dup 0x7f <= ] [ write1 ] }
            { [ dup 0xff <= ] [ 0xcc write1 write1 ] }
            { [ dup 0xffff <= ] [ 0xcd write1 2 >be write ] }
            { [ dup 0xffffffff <= ] [ 0xce write1 4 >be write ] }
            { [ dup 0xffffffffffffffff <= ] [ 0xcf write1 8 >be write ] }
            [ cannot-convert ]
        } cond
    ] [
        {
            { [ dup -0x1f >= ] [ write1 ] }
            { [ dup -0x80 >= ] [ 0xd0 write1 write1 ] }
            { [ dup -0x8000 >= ] [ 0xd1 write1 2 >be write ] }
            { [ dup -0x80000000 >= ] [ 0xd2 write1 4 >be write ] }
            { [ dup -0x8000000000000000 >= ] [ 0xd3 write1 8 >be write ] }
            [ cannot-convert ]
        } cond
    ] if ;

M: float write-msgpack
    0xcb write1 double>bits 8 >be write ;

M: string write-msgpack
    dup length {
        { [ dup 0x1f <= ] [ 0xa0 bitor write1 ] }
        { [ dup 0xff <= ] [ 0xd9 write1 write1 ] }
        { [ dup 0xffff <= ] [ 0xda write1 2 >be write ] }
        { [ dup 0xffffffff <= ] [ 0xdb write1 4 >be write ] }
        [ cannot-convert ]
    } cond output-stream get utf8 encode-string ;

M: byte-array write-msgpack
    dup length {
        { [ dup 0xff <= ] [ 0xc4 write1 write1 ] }
        { [ dup 0xffff <= ] [ 0xc5 write1 2 >be write ] }
        { [ dup 0xffffffff <= ] [ 0xc6 write1 4 >be write ] }
        [ cannot-convert ]
    } cond write ;

: write-array-header ( n -- )
    {
        { [ dup 0xf <= ] [ 0x90 bitor write1 ] }
        { [ dup 0xffff <= ] [ 0xdc write1 2 >be write ] }
        { [ dup 0xffffffff <= ] [ 0xdd write1 4 >be write ] }
        [ cannot-convert ]
    } cond ;

M: sequence write-msgpack
    dup length write-array-header [ write-msgpack ] each ;

: write-map-header ( n -- )
    {
        { [ dup 0xf <= ] [ 0x80 bitor write1 ] }
        { [ dup 0xffff <= ] [ 0xde write1 2 >be write ] }
        { [ dup 0xffffffff <= ] [ 0xdf write1 4 >be write ] }
        [ cannot-convert ]
    } cond ;

M: assoc write-msgpack
    dup assoc-size write-map-header
    [ [ write-msgpack ] bi@ ] assoc-each ;

PRIVATE>

GENERIC: msgpack> ( seq -- obj )

M: string msgpack>
    [ read-msgpack ] with-string-reader ;

M: byte-array msgpack>
    binary [ read-msgpack ] with-byte-reader ;

: >msgpack ( obj -- bytes )
    binary [ write-msgpack ] with-byte-writer ;
