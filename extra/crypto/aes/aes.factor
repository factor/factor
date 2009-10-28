! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math memoize sequences math.bitwise
locals ;
IN: crypto.aes

CONSTANT: AES_BLOCK_SIZE 16

: sbox ( -- array )
{
    HEX: 63 HEX: 7c HEX: 77 HEX: 7b HEX: f2 HEX: 6b HEX: 6f HEX: c5
    HEX: 30 HEX: 01 HEX: 67 HEX: 2b HEX: fe HEX: d7 HEX: ab HEX: 76
    HEX: ca HEX: 82 HEX: c9 HEX: 7d HEX: fa HEX: 59 HEX: 47 HEX: f0
    HEX: ad HEX: d4 HEX: a2 HEX: af HEX: 9c HEX: a4 HEX: 72 HEX: c0
    HEX: b7 HEX: fd HEX: 93 HEX: 26 HEX: 36 HEX: 3f HEX: f7 HEX: cc
    HEX: 34 HEX: a5 HEX: e5 HEX: f1 HEX: 71 HEX: d8 HEX: 31 HEX: 15
    HEX: 04 HEX: c7 HEX: 23 HEX: c3 HEX: 18 HEX: 96 HEX: 05 HEX: 9a
    HEX: 07 HEX: 12 HEX: 80 HEX: e2 HEX: eb HEX: 27 HEX: b2 HEX: 75
    HEX: 09 HEX: 83 HEX: 2c HEX: 1a HEX: 1b HEX: 6e HEX: 5a HEX: a0
    HEX: 52 HEX: 3b HEX: d6 HEX: b3 HEX: 29 HEX: e3 HEX: 2f HEX: 84
    HEX: 53 HEX: d1 HEX: 00 HEX: ed HEX: 20 HEX: fc HEX: b1 HEX: 5b
    HEX: 6a HEX: cb HEX: be HEX: 39 HEX: 4a HEX: 4c HEX: 58 HEX: cf
    HEX: d0 HEX: ef HEX: aa HEX: fb HEX: 43 HEX: 4d HEX: 33 HEX: 85
    HEX: 45 HEX: f9 HEX: 02 HEX: 7f HEX: 50 HEX: 3c HEX: 9f HEX: a8
    HEX: 51 HEX: a3 HEX: 40 HEX: 8f HEX: 92 HEX: 9d HEX: 38 HEX: f5
    HEX: bc HEX: b6 HEX: da HEX: 21 HEX: 10 HEX: ff HEX: f3 HEX: d2
    HEX: cd HEX: 0c HEX: 13 HEX: ec HEX: 5f HEX: 97 HEX: 44 HEX: 17
    HEX: c4 HEX: a7 HEX: 7e HEX: 3d HEX: 64 HEX: 5d HEX: 19 HEX: 73
    HEX: 60 HEX: 81 HEX: 4f HEX: dc HEX: 22 HEX: 2a HEX: 90 HEX: 88
    HEX: 46 HEX: ee HEX: b8 HEX: 14 HEX: de HEX: 5e HEX: 0b HEX: db
    HEX: e0 HEX: 32 HEX: 3a HEX: 0a HEX: 49 HEX: 06 HEX: 24 HEX: 5c
    HEX: c2 HEX: d3 HEX: ac HEX: 62 HEX: 91 HEX: 95 HEX: e4 HEX: 79
    HEX: e7 HEX: c8 HEX: 37 HEX: 6d HEX: 8d HEX: d5 HEX: 4e HEX: a9
    HEX: 6c HEX: 56 HEX: f4 HEX: ea HEX: 65 HEX: 7a HEX: ae HEX: 08
    HEX: ba HEX: 78 HEX: 25 HEX: 2e HEX: 1c HEX: a6 HEX: b4 HEX: c6
    HEX: e8 HEX: dd HEX: 74 HEX: 1f HEX: 4b HEX: bd HEX: 8b HEX: 8a
    HEX: 70 HEX: 3e HEX: b5 HEX: 66 HEX: 48 HEX: 03 HEX: f6 HEX: 0e
    HEX: 61 HEX: 35 HEX: 57 HEX: b9 HEX: 86 HEX: c1 HEX: 1d HEX: 9e
    HEX: e1 HEX: f8 HEX: 98 HEX: 11 HEX: 69 HEX: d9 HEX: 8e HEX: 94
    HEX: 9b HEX: 1e HEX: 87 HEX: e9 HEX: ce HEX: 55 HEX: 28 HEX: df
    HEX: 8c HEX: a1 HEX: 89 HEX: 0d HEX: bf HEX: e6 HEX: 42 HEX: 68
    HEX: 41 HEX: 99 HEX: 2d HEX: 0f HEX: b0 HEX: 54 HEX: bb HEX: 16
} ;

: inv-sbox ( -- array )
    256 0 <array>
    dup 256 [ dup sbox nth rot set-nth ] with each ;

: rcon ( -- array )
    {
        HEX: 00 HEX: 01 HEX: 02 HEX: 04 HEX: 08 HEX: 10
        HEX: 20 HEX: 40 HEX: 80 HEX: 1b HEX: 36
    } ;

: xtime ( x -- x' )
    [ 1 shift ]
    [ HEX: 80 bitand 0 = 0 HEX: 1b ? ] bi bitxor 8 bits ;

: ui32 ( a0 a1 a2 a3 -- a )
    [ 8 shift ] [ 16 shift ] [ 24 shift ] tri*
    bitor bitor bitor 32 bits ;

:: set-t ( T i -- )
    i sbox nth :> a1
    a1 xtime :> a2
    a1 a2 bitxor :> a3

    a2 a1 a1 a3 ui32 i T set-nth
    a3 a2 a1 a1 ui32 i HEX: 100 + T set-nth
    a1 a3 a2 a1 ui32 i HEX: 200 + T set-nth
    a1 a1 a3 a2 ui32 i HEX: 300 + T set-nth ;

MEMO:: t-table ( -- array )
    1024 0 <array>
    dup 256 [ set-t ] with each ;

:: set-d ( D i -- )
    i inv-sbox nth :> a1
    a1 xtime :> a2
    a2 xtime :> a4
    a4 xtime :> a8
    a8 a1 bitxor :> a9
    a9 a2 bitxor :> ab
    a9 a4 bitxor :> ad
    a8 a4 a2 bitxor bitxor :> ae

    ae a9 ad ab ui32 i D set-nth
    ab ae a9 ad ui32 i HEX: 100 + D set-nth
    ad ab ae a9 ui32 i HEX: 200 + D set-nth
    a9 ad ab ae ui32 i HEX: 300 + D set-nth ;
    
MEMO:: d-table ( -- array )
    1024 0 <array>
    dup 256 [ set-d ] with each ;


USE: multiline
/*
! : HT ( i x s -- 


TUPLE: caes #rounds2 rkey ;
! rounds / 2, rkey is a byte-array 60 long
! key size is 16, 24, 32 bytes

TUPLE: caescbc prev4 caes ;



: aes-set-key-encode ( p key -- )
    
    ;
*/
