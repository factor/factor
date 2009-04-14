! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
! 
USING: tools.test kernel serialize io io.streams.byte-array math
alien arrays byte-arrays bit-arrays specialized-arrays.double
sequences math prettyprint parser classes math.constants
io.encodings.binary random assocs serialize.private ;
IN: serialize.tests

: test-serialize-cell ( a -- ? )
    2^ random dup
    binary [ serialize-cell ] with-byte-writer
    binary [ deserialize-cell ] with-byte-reader = ;

[ t ] [
    100 [
        drop
        40 [        test-serialize-cell ] all?
         4 [ 40 *   test-serialize-cell ] all?
         4 [ 400 *  test-serialize-cell ] all?
         4 [ 4000 * test-serialize-cell ] all?
        and and and
    ] all?
] unit-test

TUPLE: serialize-test a b ;

C: <serialize-test> serialize-test

CONSTANT: objects
    {
        f
        t
        0
        -50
        20
        5.25
        -5.25
        C{ 1 2 }
        1/2
        "test"
        { 1 2 "three" }
        V{ 1 2 "three" }
        SBUF" hello world"
        "hello \u123456 unicode"
        \ dup
        [ \ dup dup ]
        T{ serialize-test f "a" 2 }
        B{ 50 13 55 64 1 }
        ?{ t f t f f t f }
        double-array{ 1.0 3.0 4.0 1.0 2.35 0.33 }
        << 1 [ 2 ] curry parsed >>
        { { "a" "bc" } { "de" "fg" } }
        H{ { "a" "bc" } { "de" "fg" } }
    }

: check-serialize-1 ( obj -- ? )
    "=====" print
    dup class .
    dup .
    dup
    object>bytes
    bytes>object
    dup . = ;

: check-serialize-2 ( obj -- ? )
    dup number? over wrapper? or [
        drop t ! we don't care if numbers aren't interned
    ] [
        "=====" print
        dup class .
        dup 2array dup .
        object>bytes
        bytes>object dup .
        first2 eq?
    ] if ;

[ t ] [ objects [ check-serialize-1 ] all? ] unit-test

[ t ] [ objects [ check-serialize-2 ] all? ] unit-test

[ t ] [ pi check-serialize-1 ] unit-test
[ serialize ] must-infer
[ deserialize ] must-infer

[ t ] [
    V{ } dup dup push
    object>bytes
    bytes>object
    dup first eq?
] unit-test

[ t ] [
    H{ } dup dup dup set-at
    object>bytes
    bytes>object
    dup keys first eq?
] unit-test
