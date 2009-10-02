! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types kernel locals math math.ranges
math.bitwise math.vectors math.vectors.simd random
sequences specialized-arrays sequences.private classes.struct ;
SIMD: uint
SPECIALIZED-ARRAY: uint
SPECIALIZED-ARRAY: uint-4
IN: random.sfmt

<PRIVATE

CONSTANT: state-multiplier 1812433253

STRUCT: sfmt-state
    { seed uint }
    { n uint }
    { m uint }
    { ix uint }
    { mask uint-4 }
    { r1 uint-4 }
    { r2 uint-4 } ;

TUPLE: sfmt
    { state sfmt-state }
    { uint-array uint-array }
    { uint-4-array uint-4-array } ;

: wA ( w -- wA )
   dup 1 hlshift vbitxor ; inline

: wB ( w mask -- wB )
   [ 11 vrshift ] dip vbitand ; inline

: wC ( w -- wC )
   1 hrshift ; inline

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
    state n>> 2 - array nth state (>>r1)
    state n>> 1 - array nth state (>>r2)
    state m>> :> m 
    state n>> :> n 
    state mask>> :> mask

    n m - >fixnum iota [| i |
        i array nth-unsafe 
        i m + array nth-unsafe
        mask state r1>> state r2>> formula :> r

        r i array set-nth-unsafe
        state r2>> state (>>r1)
        r state (>>r2)
    ] each

    ! n m - 1 + n [a,b) [
    m 1 - iota [
        n m - 1 + + >fixnum :> i
        i array nth-unsafe
        m n - i + array nth-unsafe
        mask state r1>> state r2>> formula :> r

        r i array set-nth-unsafe
        state r2>> state (>>r1)
        r state (>>r2)
    ] each
    
    0 state (>>ix) ;

: <sfmt-array> ( sfmt -- uint-array uint-4-array )
    state>> 
    [ n>> 4 * iota >uint-array ] [ seed>> ] bi
    [
        [
            [
                [ -30 shift ] [ ] bi bitxor
                state-multiplier * 32 bits
            ] dip +
        ] unless-zero 32 bits
    ] uint-array{ } accumulate-as nip
    dup underlying>> byte-array>uint-4-array ;

: <sfmt-state> ( seed n m mask -- sfmt )
    sfmt-state <struct>
        swap >>mask
        swap >>m
        swap >>n
        swap >>seed
        0 >>ix ;

: init-sfmt ( sfmt -- sfmt' )
    dup <sfmt-array> [ >>uint-array ] [ >>uint-4-array ] bi*
    [ generate ] keep ; inline

: <sfmt> ( seed n m mask -- sfmt )
    <sfmt-state>
    sfmt new
        swap >>state
        init-sfmt ; inline

: refill-sfmt? ( sfmt -- ? )
    state>> [ ix>> ] [ n>> 4 * ] bi >= ;

: next-ix ( sfmt -- ix )
    state>> [ dup 1 + ] change-ix drop ; inline

: next ( sfmt -- n )
    [ next-ix ] [ uint-array>> ] bi nth-unsafe ; inline

PRIVATE>

M: sfmt random-32* ( sfmt -- n )
    dup refill-sfmt? [ dup generate ] when next ; inline

M: sfmt seed-random ( sfmt seed -- sfmt )
    [ [ state>> ] dip >>seed drop ]
    [ drop init-sfmt ] 2bi ;

: <sfmt-19937> ( seed -- sfmt )
    348 330 uint-4{ HEX: BFFFFFF6 HEX: BFFAFFFF HEX: DDFECB7F HEX: DFFFFFEF }
    <sfmt> ; inline
