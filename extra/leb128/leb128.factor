! Copyright (C) 2023 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: byte-arrays byte-vectors combinators hints io kernel math
math.bitwise namespaces sequences typed ;

IN: leb128

! Unsigned LEB128

<PRIVATE

:: (write-uleb128) ( n quot: ( b -- ) -- )
    n assert-non-negative [
        [ -7 shift dup 0 = not ] [ 7 bits ] bi
        over [ 0x80 bitor ] when quot call
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

TYPED: uleb128> ( byte-array: byte-array -- n )
    0 [ [ 0x7f bitand ] [ 7 * shift ] bi* + ] reduce-index ;

! Signed LEB128

<PRIVATE

:: (write-leb128) ( n quot: ( b -- ) -- )
    n [
        [ -7 shift dup ] [ 0x7f bitand ] bi :> ( i b )
        {
            { [ i  0 = ] [ b 6 bit? not ] }
            { [ i -1 = ] [ b 6 bit? ] }
            [ f ]
        } cond [ f b ] [ t b 0x80 bitor ] if quot call
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

TYPED: leb128> ( byte-array: byte-array -- n )
    [ uleb128> ] keep dup last 6 bit?
    [ length 7 * 2^ neg bitor ] [ drop ] if ;
