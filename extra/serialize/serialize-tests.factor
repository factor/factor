! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
! 
USING: tools.test kernel serialize io io.streams.string math
alien arrays byte-arrays sequences math prettyprint ;
IN: temporary

TUPLE: serialize-test a b ;

C: <serialize-test> serialize-test

: CURRY< \ > parse-until first2 curry parsed ; parsing

: objects
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
        \ dup
        [ \ dup dup ]
        T{ serialize-test f "a" 2 }
        B{ 50 13 55 64 1 }
        ?{ t f t f f t f }
        F{ 1.0 3.0 4.0 1.0 2.35 0.33 }
        CURRY< 1 [ 2 ] >
        { { "a" "bc" } { "de" "fg" } }
        H{ { "a" "bc" } { "de" "fg" } }
    } ;

: check-serialize-1 ( obj -- ? )
    dup class .
    dup [ serialize ] string-out
    [ deserialize ] string-in = ;

: check-serialize-2 ( obj -- ? )
    dup number? over wrapper? or [
        drop t ! we don't care if numbers aren't interned
    ] [
        dup class .
        dup 2array
        [ serialize ] string-out
        [ deserialize ] string-in
        first2 eq?
    ] if ;

[ t ] [ objects [ check-serialize-1 ] all? ] unit-test

[ t ] [ objects [ check-serialize-2 ] all? ] unit-test

[ t ] [ pi check-serialize-1 ] unit-test
