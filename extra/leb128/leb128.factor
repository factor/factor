! Copyright (C) 2023 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: byte-vectors combinators.short-circuit hints io
io.streams.byte-array kernel math namespaces sequences typed ;

IN: leb128

! Unsigned LEB128

<PRIVATE

:: (write-uleb128) ( n quot: ( b -- ) -- )
    n assert-non-negative [
        [ -7 shift dup ] [ 0x7f bitand ] bi :> ( i b )
        dup zero? [ f b ] [ t b 0x80 bitor ] if
        quot call
    ] loop drop ; inline

HINTS: (write-uleb128) { fixnum object } ;

PRIVATE>

TYPED: stream-write-uleb128 ( n: integer stream -- )
    '[ _ stream-write1 ] (write-uleb128) ; inline

: write-uleb128 ( n -- )
    output-stream get stream-write-uleb128 ;

TYPED: >uleb128 ( n: integer -- byte-array )
    16 <byte-vector> [ '[ _ push ] (write-uleb128) ] keep B{ } like ;

:: stream-read-uleb128 ( stream -- n )
    0 0 [
        stream stream-read1 :> ( i b )
        b 0x7f bitand i 7 * shift +
        i 1 + b 7 bit?
    ] loop drop ;

: read-uleb128 ( -- n )
    input-stream get stream-read-uleb128 ;

: uleb128> ( byte-array -- n )
    0 byte-reader boa stream-read-uleb128 ;

! Signed LEB128

<PRIVATE

:: (write-leb128) ( n quot: ( b -- ) -- )
    n [
        [ -7 shift dup ] [ 0x7f bitand ] bi :> ( i b )
        {
            [ i zero? b 6 bit? not and ]
            [ i -1 = b 6 bit? and ]
        } 0|| [ f b ] [ t b 0x80 bitor ] if
        quot call
    ] loop drop ; inline

HINTS: (write-leb128) { fixnum object } ;

PRIVATE>

TYPED: stream-write-leb128 ( n: integer stream -- )
    '[ _ stream-write1 ] (write-leb128) ;

: write-leb128 ( n -- )
    output-stream get stream-write-leb128 ;

TYPED: >leb128 ( n: integer -- byte-array )
    16 <byte-vector> [ '[ _ push ] (write-leb128) ] keep B{ } like ;

:: stream-read-leb128 ( stream -- n )
    0 0 [
        stream stream-read1 :> ( i b )
        b 0x7f bitand i 7 * shift +
        i 1 + b 7 bit? dup [
            b 6 bit? [
                [ [ 7 * 2^ neg bitor ] keep ] dip
            ] when
        ] unless
    ] loop drop ;

: read-leb128 ( -- n )
    input-stream get stream-read-leb128 ;

: leb128> ( byte-array -- n )
    0 byte-reader boa stream-read-leb128 ;
