! Copyright (C) 2019 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs base64 byte-arrays calendar
calendar.format calendar.parser combinators endian io
io.encodings.binary io.encodings.string io.encodings.utf8
io.streams.byte-array io.streams.string kernel linked-assocs
math math.bitwise math.floats.half present sequences strings
urls ;

IN: cbor

DEFER: read-cbor

SINGLETON: +cbor-nil+

SINGLETON: +cbor-undefined+

SINGLETON: +cbor-break+

SINGLETON: +cbor-indefinite+

TUPLE: cbor-tagged tag item ;

TUPLE: cbor-simple value ;

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
        read [ B{ } ] unless*
    ] if ;

: read-textstring ( info -- string )
    read-bytestring utf8 decode ;

: read-array ( info -- array )
    read-unsigned dup +cbor-indefinite+ = [
        drop [ read-cbor dup +cbor-break+ = not ] [ ] produce nip
    ] [
        [ read-cbor ] replicate
    ] if ;

: read-map ( info -- assoc )
    read-unsigned dup +cbor-indefinite+ = [
        drop [ read-cbor dup +cbor-break+ = not ]
        [ read-cbor 2array ] produce nip
    ] [
        [ read-cbor read-cbor 2array ] replicate
    ] if >linked-hash ;

: read-tagged ( info -- tagged )
    read-unsigned read-cbor swap {
        { 0 [ rfc3339>timestamp ] }
        { 1 [ unix-time>timestamp ] }
        { 2 [ be> ] }
        { 3 [ be> neg 1 - ] }
        { 32 [ >url ] }
        { 33 [ base64> ] }
        [ swap cbor-tagged boa ]
    } case ;

: read-float ( info -- float )
    dup 20 < [ cbor-simple boa ] [
        {
            { 20 [ f ] }
            { 21 [ t ] }
            { 22 [ +cbor-nil+ ] }
            { 23 [ +cbor-undefined+ ] }
            { 24 [ read1 cbor-simple boa ] }
            { 25 [ 2 read be> bits>half ] }
            { 26 [ 4 read be> bits>float ] }
            { 27 [ 8 read be> bits>double ] }
            { 31 [ +cbor-break+ ] }
        } case
    ] if ;

PRIVATE>

: read-cbor ( -- obj )
    read1 [ 5 bits ] [ -5 shift 3 bits ] bi {
        { 0 [ read-unsigned ] }
        { 1 [ read-unsigned neg 1 - ] }
        { 2 [ read-bytestring ] }
        { 3 [ read-textstring ] }
        { 4 [ read-array ] }
        { 5 [ read-map ] }
        { 6 [ read-tagged ] }
        { 7 [ read-float ] }
    } case ;

GENERIC: write-cbor ( obj -- )

<PRIVATE

M: f write-cbor drop 0xf4 write1 ;

M: t write-cbor drop 0xf5 write1 ;

M: +cbor-nil+ write-cbor drop 0xf6 write1 ;

M: +cbor-undefined+ write-cbor drop 0xf7 write1 ;

: write-integer ( n type -- )
    5 shift {
        { [ over 24 < ] [ bitor write1 ] }
        { [ over 0xff <= ] [ 24 bitor write1 write1 ] }
        { [ over 0xffff <= ] [ 25 bitor write1 2 >be write ] }
        { [ over 0xffffffff <= ] [ 26 bitor write1 4 >be write ] }
        { [ over 0xffffffffffffffff <= ] [ 27 bitor write1 8 >be write ] }
        [
            -5 shift 2 + 0xc0 bitor write1
            dup bit-length 8 /mod zero? [ 1 + ] unless
            >be write-cbor
        ]
    } cond ;

M: integer write-cbor
    dup 0 >= [ 0 write-integer ] [ neg 1 - 1 write-integer ] if ;

M: float write-cbor 0xfb write1 double>bits 8 >be write ;

M: byte-array write-cbor dup length 2 write-integer write ;

M: string write-cbor dup length 3 write-integer utf8 encode write ;

M: sequence write-cbor
    dup length 4 write-integer [ write-cbor ] each ;

M: assoc write-cbor
    dup assoc-size 5 write-integer [ [ write-cbor ] bi@ ] assoc-each ;

M: timestamp write-cbor
    0 6 write-integer timestamp>rfc3339 write-cbor ;

M: url write-cbor
    32 6 write-integer present write-cbor ;

M: cbor-tagged write-cbor
    dup tag>> 6 write-integer item>> write-cbor ;

M: cbor-simple write-cbor
    value>> 7 write-integer ;

PRIVATE>

GENERIC: cbor> ( seq -- obj )

M: string cbor>
    [ read-cbor ] with-string-reader ;

M: byte-array cbor>
    binary [ read-cbor ] with-byte-reader ;

: >cbor ( obj -- bytes )
    binary [ write-cbor ] with-byte-writer ;
