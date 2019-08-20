! Copyright (C) 2019 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays assocs byte-arrays combinators io io.binary
io.encodings.binary io.encodings.string io.encodings.utf8
io.streams.byte-array io.streams.string kernel math
math.bitwise math.floats.half sequences strings ;

IN: cbor

DEFER: read-cbor

SINGLETON: +cbor-nil+

SINGLETON: +cbor-undefined+

SINGLETON: +cbor-break+

SINGLETON: +cbor-indefinite+

<PRIVATE

: read-unsigned ( info -- n )
    dup 24 < [
        {
            { 24 [ read1 ] }
            { 25 [ 2 read be> ] }
            { 26 [ 4 read be> ] }
            { 27 [ 8 read be> ] }
            { 31 [ +cbor-indefinite+ ] }
        } case
    ] unless ;

: read-bytestring ( info -- byte-array )
    read-unsigned dup +cbor-indefinite+ = [
        drop [ read-cbor dup +cbor-break+ = not ] [ ] produce nip concat
    ] [
        read
    ] if ;

: read-textstring ( info -- string )
    read-bytestring utf8 decode ;

: read-array ( info -- array )
    read-unsigned dup +cbor-indefinite+ = [
        drop [ read-cbor dup +cbor-break+ = not ] [ ] produce nip
    ] [
        [ read-cbor ] replicate
    ] if ;

: read-map ( info -- alist )
    read-unsigned dup +cbor-indefinite+ = [
        drop [ read-cbor dup +cbor-break+ = not ]
        [ read-cbor 2array ] produce nip
    ] [
        [ read-cbor read-cbor 2array ] replicate
    ] if ;

: read-float ( info -- float )
    {
        { 20 [ f ] }
        { 21 [ t ] }
        { 22 [ +cbor-nil+ ] }
        { 23 [ +cbor-undefined+ ] }
        { 25 [ 2 read be> bits>half ] }
        { 26 [ 4 read be> bits>float ] }
        { 27 [ 8 read be> bits>double ] }
        { 31 [ +cbor-break+ ] }
    } case ;

PRIVATE>

: read-cbor ( -- obj )
    read1 [ 5 bits ] [ -5 shift 3 bits ] bi {
        { 0 [ read-unsigned ] }
        { 1 [ read-unsigned neg 1 - ] }
        { 2 [ read-bytestring ] }
        { 3 [ read-textstring ] }
        { 4 [ read-array ] }
        { 5 [ read-map ] }
        { 6 [ "optional semantic tagging not supported" throw ] }
        { 7 [ read-float ] }
    } case ;

GENERIC: write-cbor ( obj -- )

<PRIVATE

M: f write-cbor drop 0xf4 write1 ;

M: t write-cbor drop 0xf5 write1 ;

M: +cbor-nil+ write-cbor drop 0xf6 write1 ;

M: +cbor-undefined+ write-cbor drop 0xf7 write1 ;

M: integer write-cbor
    dup 0 >= [
        {
            { [ dup 24 < ] [ write1 ] }
            { [ dup 0xff <= ] [ 24 write1 write1 ] }
            { [ dup 0xffff <= ] [ 25 write1 2 >be write ] }
            { [ dup 0xffffffff <= ] [ 26 write1 4 >be write ] }
            { [ dup 0xffffffffffffffff <= ] [ 27 write1 8 >be write ] }
        } cond
    ] [
        drop
    ] if ;

M: float write-cbor 0xfb write1 double>bits 8 >be write ;

: write-length ( type n -- )
    [ 5 shift ] dip {
        { [ dup 24 < ] [ bitor write1 ] }
        { [ dup 0xff <= ] [ 24 bitor write1 write1 ] }
        { [ dup 0xffff <= ] [ 25 bitor write1 2 >be write ] }
        { [ dup 0xffffffff <= ] [ 26 bitor write1 4 >be write ] }
        { [ dup 0xffffffffffffffff <= ] [ 27 bitor write1 8 >be write ] }
    } cond ;

M: byte-array write-cbor 2 over length write-length write ;

M: string write-cbor 3 over length write-length utf8 encode write ;

M: sequence write-cbor
    4 over length write-length [ write-cbor ] each ;

M: assoc write-cbor
    5 over length write-length [ [ write-cbor ] bi@ ] assoc-each ;

PRIVATE>

GENERIC: cbor> ( seq -- obj )

M: string cbor>
    [ read-cbor ] with-string-reader ;

M: byte-array cbor>
    binary [ read-cbor ] with-byte-reader ;

: >cbor ( obj -- bytes )
    binary [ write-cbor ] with-byte-writer ;
