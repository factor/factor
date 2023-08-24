! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data kernel math namespaces
random sequences sequences.private specialized-arrays ;
SPECIALIZED-ARRAY: double
IN: random.lagged-fibonacci

TUPLE: lagged-fibonacci { u double-array } { pt0 fixnum } { pt1 fixnum } ;

<PRIVATE

CONSTANT: p-r 1278
CONSTANT: q-r 417

CONSTANT: lagged-fibonacci 899999963
CONSTANT: lagged-fibonacci-max-seed 900000000
CONSTANT: lagged-fibonacci-sig-bits 24

: normalize-seed ( seed -- seed' )
    abs lagged-fibonacci-max-seed mod ; inline

: adjust-ptr ( ptr -- ptr' )
    1 - dup 0 < [ drop p-r ] when ; inline

PRIVATE>

M:: lagged-fibonacci seed-random ( lagged-fibonacci seed! -- lagged-fibonacci )
    seed normalize-seed seed!
    seed 30082 /i :> ij
    seed 30082 ij * - :> kl
    ij 177 /i 177 mod 2 + :> i!
    ij 177 mod 2 + :> j!
    kl 169 /i 178 mod 1 + :> k!
    kl 169 mod :> l!

    lagged-fibonacci u>> [
        drop
        0.0 :> s!
        0.5 :> t!
        0.0 :> m!
        lagged-fibonacci-sig-bits [
            i j * 179 mod k * 179 mod m!
            j i!
            k j!
            m k!
            53 l * 1 + 169 mod l!
            l m * 64 mod 31 > [ s t + s! ] when
            t 0.5 * t!
        ] times
        s
    ] map! drop
    lagged-fibonacci p-r >>pt0
        q-r >>pt1 ; inline

: <lagged-fibonacci> ( seed -- lagged-fibonacci )
    lagged-fibonacci new
        p-r 1 + double <c-array> >>u
        swap seed-random ; inline

GENERIC: random-float* ( tuple -- r )

: random-float ( -- n ) random-generator get random-float* ; inline

M:: lagged-fibonacci random-float* ( lagged-fibonacci -- x )
    lagged-fibonacci [ pt0>> ] [ u>> ] bi nth-unsafe
    lagged-fibonacci [ pt1>> ] [ u>> ] bi nth-unsafe -
    dup 0.0 < [ 1.0 + ] when
    [
        lagged-fibonacci [ pt0>> ] [ u>> ] bi set-nth-unsafe
        lagged-fibonacci [ adjust-ptr ] change-pt0 drop
        lagged-fibonacci [ adjust-ptr ] change-pt1 drop
    ] keep ; inline

: default-lagged-fibonacci ( -- obj )
    [ random-32 ] with-system-random <lagged-fibonacci> ; inline
