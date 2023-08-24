! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data kernel locals math
ranges math.bitwise math.vectors math.vectors.simd random
sequences specialized-arrays sequences.private classes.struct
combinators.short-circuit fry ;
SPECIALIZED-ARRAY: uint
SPECIALIZED-ARRAY: uint-4
IN: random.sfmt

<PRIVATE

CONSTANT: state-multiplier 1812433253

STRUCT: sfmt-state
    { seed uint }
    { n uint }
    { m uint }
    { index uint }
    { mask uint-4 }
    { parity uint-4 }
    { r1 uint-4 }
    { r2 uint-4 } ;

TUPLE: sfmt
    { state sfmt-state }
    { uint-array uint-array }
    { uint-4-array uint-4-array } ;

: endian-shuffle ( v -- w )
    little-endian? [
        uchar-16{ 3 2 1 0 7 6 5 4 11 10 9 8 15 14 13 12 } vshuffle
    ] unless ; inline

: hlshift* ( v n -- w )
    [ endian-shuffle ] dip hlshift endian-shuffle ; inline

: hrshift* ( v n -- w )
    [ endian-shuffle ] dip hrshift endian-shuffle ; inline

: wA ( w -- wA )
    dup 1 hlshift* vbitxor ; inline

: wB ( w mask -- wB )
    [ 11 vrshift ] dip vbitand ; inline

: wC ( w -- wC )
    1 hrshift* ; inline

: wD ( w -- wD )
    18 vlshift ; inline

: formula ( a b mask c d -- r )
    [ wC ] dip wD vbitxor
    [ wB ] dip vbitxor
    [ wA ] dip vbitxor ; inline

GENERIC: generate ( sfmt -- )

M:: sfmt generate ( sfmt -- )
    sfmt state>> :> state
    sfmt uint-4-array>> :> array
    state n>> 2 - array nth state r1<<
    state n>> 1 - array nth state r2<<
    state m>> :> m
    state n>> :> n
    state mask>> :> mask

    n m - >fixnum <iota> [| i |
        i array nth-unsafe
        i m + array nth-unsafe
        mask state r1>> state r2>> formula :> r

        r i array set-nth-unsafe
        state r2>> state r1<<
        r state r2<<
    ] each

    ! n m - 1 + n [a..b) [
    m 1 - <iota> [
        n m - 1 + + >fixnum :> i
        i array nth-unsafe
        m n - i + array nth-unsafe
        mask state r1>> state r2>> formula :> r

        r i array set-nth-unsafe
        state r2>> state r1<<
        r state r2<<
    ] each

    0 state index<< ;

: period-certified? ( sfmt -- ? )
    [ uint-4-array>> first ]
    [ state>> parity>> ] bi vbitand odd-parity? ;

: first-set-bit ( x -- n )
    0 swap [
        dup { [ 0 > ] [ 1 bitand 0 = ] } 1&&
    ] [
        [ 1 + ] [ -1 shift ] bi*
    ] while drop ;

: correct-period ( sfmt -- )
    [ drop 0 ]
    [ state>> parity>> first first-set-bit ]
    [ uint-array>> swap '[ _ toggle-bit ] change-nth ] tri ;

: certify-period ( sfmt -- sfmt )
    dup period-certified? [ dup correct-period ] unless ;

: <sfmt-array> ( sfmt -- uint-array uint-4-array )
    state>>
    [ n>> 4 * [1..b] uint >c-array ] [ seed>> ] bi
    [
        [
            [ -30 shift ] [ ] bi bitxor
            state-multiplier w*
        ] dip w+
    ] uint-array{ } accumulate-as nip
    dup uint-4 cast-array ;

: <sfmt-state> ( seed n m mask parity -- sfmt )
    sfmt-state new
        swap >>parity
        swap >>mask
        swap >>m
        swap >>n
        swap >>seed
        0 >>index ;

: init-sfmt ( sfmt -- sfmt' )
    dup <sfmt-array> [ >>uint-array ] [ >>uint-4-array ] bi*
    certify-period [ generate ] keep ; inline

: <sfmt> ( seed n m mask parity -- sfmt )
    <sfmt-state>
    sfmt new
        swap >>state
        init-sfmt ; inline

: refill-sfmt? ( sfmt -- ? )
    state>> [ index>> ] [ n>> 4 * ] bi >= ; inline

: next-index ( sfmt -- index )
    state>> [ dup 1 + ] change-index drop ; inline

: next ( sfmt -- n )
    [ next-index ] [ uint-array>> ] bi nth-unsafe ; inline

PRIVATE>

M: sfmt random-32*
    dup refill-sfmt? [ dup generate ] when next ; inline

M: sfmt seed-random
    [ [ state>> ] dip >>seed drop ]
    [ drop init-sfmt ] 2bi ;

: <sfmt-19937> ( seed -- sfmt )
    156 122
    uint-4{ 0xdfffffef 0xddfecb7f 0xbffaffff 0xbffffff6 }
    uint-4{ 0x1 0x0 0x0 0x13c9e684 }
    <sfmt> ; inline

: default-sfmt ( -- sfmt )
    [ random-32 ] with-secure-random <sfmt-19937> ;
