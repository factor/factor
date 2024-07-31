! Copyright (C) 2018 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types classes.struct kernel math
math.bitwise random sequences slots.syntax ;
IN: random.xoshiro

! https://xoshiro.di.unimi.it/xoshiro256starstar.c

CONSTANT: JUMP-256 {
    0x180ec6d33cfd0aba
    0xd5a61266f0c9392c
    0xa9582618e03fc9aa
    0x39abdc4529b1661c
}

CONSTANT: LONG-JUMP-256 {
    0x76e15d3efefdcbbf
    0xc5004e441c522fb3
    0x77710069854ee241
    0x39109bb02acbe635
}

STRUCT: xoshiro-256-star-star { s0 ulonglong } { s1 ulonglong } { s2 ulonglong } { s3 ulonglong } ;

: <xoshiro-256-star-star> ( s0 s1 s2 s3 -- obj )
    xoshiro-256-star-star new
        swap >>s3
        swap >>s2
        swap >>s1
        swap >>s0 ; inline

: rotl-256 ( x: uint64_t k: int -- out: uint64_t )
    [ shift ]
    [ 64 swap - neg shift ] 2bi bitor 64 bits ; inline

:: (next-256) ( s0! s1! s2! s3! -- s0 s1 s2 s3 64-random-bits )
    s1 5 * 7 rotl-256 9 * 64 bits :> 64-random-bits
    s1 17 shift 64 bits :> t
    s0 s2 bitxor s2!
    s1 s3 bitxor s3!
    s2 s1 bitxor s1!
    s3 s0 bitxor s0!
    s2 t bitxor s2!
    s3 45 rotl-256 s3!
    s0 s1 s2 s3 64-random-bits ; inline

: next-256 ( xoshiro-256-star-star -- r64 )
    dup get[ s0 s1 s2 s3 ] (next-256)
    [ set[ s0 s1 s2 s3 ] drop ] dip ; 

:: jump ( s0! s1! s2! s3! jump-table -- s0' s1' s2' s3' )
    0 0 0 0 :> ( t0! t1! t2! t3! )
    4 <iota> [
        64 <iota> [
        [ jump-table nth ] [ 1 swap shift ] bi* bitand 0 > [
            s0 t0 bitxor t0!
            s1 t1 bitxor t1!
            s2 t2 bitxor t2!
            s3 t3 bitxor t3!
        ] when
        s0 s1 s2 s3 (next-256) drop s3! s2! s1! s0!
        ] with each
    ] each
    t0 t1 t2 t3 ;

: jump-256 ( s0 s1 s2 s3 -- s0' s1' s2' s3' ) JUMP-256 jump ;
: long-jump-256 ( s0 s1 s2 s3 -- s0' s1' s2' s3' ) LONG-JUMP-256 jump ;

M: xoshiro-256-star-star random-32*
    next-256 ;

INSTANCE: xoshiro-256-star-star base-random
