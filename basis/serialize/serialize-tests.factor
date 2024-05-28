! Copyright (C) 2006 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
!
USING: tools.test kernel serialize io io.streams.byte-array
alien arrays byte-arrays bit-arrays specialized-arrays
sequences math prettyprint parser classes math.constants
io.encodings.binary random assocs serialize.private alien.c-types
combinators.short-circuit literals ;
SPECIALIZED-ARRAY: double
IN: serialize.tests

: (test-serialize-cell) ( n -- ? )
    dup
    binary [ serialize-cell ] with-byte-writer
    binary [ deserialize-cell ] with-byte-reader = ;

: test-serialize-cell ( a -- ? )
    2^ random (test-serialize-cell) ;

{ t } [
    100 [
        drop
        {
            [ 40 [        test-serialize-cell ] all-integers? ]
            [  4 [ 40 *   test-serialize-cell ] all-integers? ]
            [  4 [ 400 *  test-serialize-cell ] all-integers? ]
            [  4 [ 4000 * test-serialize-cell ] all-integers? ]
        } 0&&
    ] all-integers?
] unit-test

{ t } [ 2000 [
        2^ 3 [ 1 - + (test-serialize-cell) ] with all-integers?
    ] all-integers?
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
        "hello \u012345 unicode"
        \ dup
        [ \ dup dup ]
        T{ serialize-test f "a" 2 }
        B{ 50 13 55 64 1 }
        ?{ t f t f f t f }
        double-array{ 1.0 3.0 4.0 1.0 2.35 0.33 }
        << 1 [ 2 ] curry suffix! >>
        { { "a" "bc" } { "de" "fg" } }
        H{ { "a" "bc" } { "de" "fg" } }
    }

: check-serialize-1 ( obj -- ? )
    "=====" print
    dup class-of .
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
        dup class-of .
        dup 2array dup .
        object>bytes
        bytes>object dup .
        first2 eq?
    ] if ;

{ t } [ objects [ check-serialize-1 ] all? ] unit-test

{ t } [ objects [ check-serialize-2 ] all? ] unit-test

{ t } [ pi check-serialize-1 ] unit-test
[ serialize ] must-infer
[ deserialize ] must-infer

{ t } [
    V{ } dup dup push
    object>bytes
    bytes>object
    dup first eq?
] unit-test

{ t } [
    H{ } dup dup dup set-at
    object>bytes
    bytes>object
    dup keys first eq?
] unit-test

! Changed the serialization of numbers in [2^1008;2^1024[
! check backwards compatibility
${ 1008 2^ } [ B{
    255 1 127 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0
} binary [ deserialize-cell ] with-byte-reader ] unit-test

${ 1024 2^ 1 - } [ B{
    255 1 128 255 255 255 255 255 255 255 255 255 255 255 255
    255 255 255 255 255 255 255 255 255 255 255 255 255 255 255
    255 255 255 255 255 255 255 255 255 255 255 255 255 255 255
    255 255 255 255 255 255 255 255 255 255 255 255 255 255 255
    255 255 255 255 255 255 255 255 255 255 255 255 255 255 255
    255 255 255 255 255 255 255 255 255 255 255 255 255 255 255
    255 255 255 255 255 255 255 255 255 255 255 255 255 255 255
    255 255 255 255 255 255 255 255 255 255 255 255 255 255 255
    255 255 255 255 255 255 255 255 255 255 255
} binary [ deserialize-cell ] with-byte-reader ] unit-test

{ H{ { 1 "foo" } } H{ { 1 "boo" } } } [
    H{ { 1 "foo" } } dup deep-clone
    CHAR: b 0 pick 1 of set-nth
] unit-test
