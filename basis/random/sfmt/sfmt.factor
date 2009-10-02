! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types kernel locals math math.ranges
math.bitwise math.vectors math.vectors.simd random
sequences specialized-arrays ;
IN: random.sfmt

SIMD: uint
SPECIALIZED-ARRAY: uint
SPECIALIZED-ARRAY: uint-4

CONSTANT: SFMT_N 156
CONSTANT: SFMT_M 122

CONSTANT: state-multiplier 1812433253

TUPLE: sfmt
sl1 sl2 sr1 sr2 mask parity
{ seed integer } { n fixnum } { m fixnum }
{ m-n fixnum } { ix fixnum } { state uint-4-array } ;

: init-state ( sfmt -- sfmt' )
    dup [ n>> 4 * iota >uint-array ] [ seed>> ] bi
    [
        [
            [
                [ -30 shift ] [ ] bi bitxor
                state-multiplier * 32 bits
            ] dip +
        ] unless-zero 32 bits
    ] uint-array{ } accumulate-as nip underlying>> byte-array>uint-4-array
    >>state ;

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

GENERIC: generate ( sfmt -- sfmt' )

M:: sfmt generate ( sfmt -- sfmt' )
    sfmt n>> 2 - sfmt state>> nth :> r1!
    sfmt n>> 1 - sfmt state>> nth :> r2!
    0 :> r!
    0 :> i!
    sfmt m>> :> m 
    sfmt n>> :> n 
    sfmt m-n>> :> m-n
    sfmt mask>> :> mask
    sfmt state>> :> state

    n m - iota [
        i!
        i state nth 
        i m + state nth
        mask r1 r2 formula r!

        r i state set-nth
        r2 r1!
        r r2!
    ] each

    n m - 1 + n [a,b) [
        i!
        i state nth 
        m-n i + state nth
        mask r1 r2 formula r!

        r i state set-nth
        r2 r1!
        r r2!
    ] each
    
    sfmt 0 >>ix ;

: <sfmt> ( seed n m sl1 sl2 sr1 sr2 mask parity -- sfmt )
    sfmt new
        swap >>parity
        swap >>mask
        swap >>sr2
        swap >>sr1
        swap >>sl2
        swap >>sl1
        swap >>m
        swap >>n
        swap 32 bits >>seed
        dup [ m>> ] [ n>> ] bi - >>m-n
        0 >>ix
        init-state
        generate ;

: <sfmt-19937> ( seed -- sfmt )
    348 330 5 3 9 3 
    uint-4{ HEX: BFFFFFF6 HEX: BFFAFFFF HEX: DDFECB7F HEX: DFFFFFEF }
    uint-4{ HEX: ecc1327a HEX: a3ac4000 HEX: 0 HEX: 1 }
    <sfmt> ;

: refill-sfmt? ( sfmt -- ? )
    [ ix>> ] [ n>> 4 * ] bi >= ;

: nth-sfmt ( sfmt -- n )
    [ ix>> 4 /mod swap ]
    [ state>> nth nth ]
    [ [ 1 + ] change-ix drop ] tri ; inline

M: sfmt random-32* ( sfmt -- n )
    dup refill-sfmt? [ generate ] when
    nth-sfmt ;
