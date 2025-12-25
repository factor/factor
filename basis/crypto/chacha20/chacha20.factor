! Copyright (C) 2025 Zoltán Kéri <z@zolk3ri.name>
! See https://factorcode.org/license.txt for BSD license.
!
! ChaCha20 stream cipher (RFC 8439)
!
! Key:     8 u32 values (256 bits) or 32 bytes
! Nonce:   3 u32 values (96 bits) or 12 bytes
! Counter: Starting block counter (usually 0 or 1)
!
! Byte order: bytes 00 01 02 03 become u32 0x03020100 (little-endian).
!
! Example (u32 arrays):
!   "Hello" >byte-array 8 0 <array> 3 0 <array> 1 chacha20-crypt
!   8 0 <array> 3 0 <array> 1 chacha20-crypt >string
!   ! => "Hello"
!
! Example (byte arrays):
!   "Hello" 32 <byte-array> 12 <byte-array> 1 chacha20-encrypt-string
!   32 <byte-array> 12 <byte-array> 1 chacha20-decrypt-string
!   ! => "Hello"
!
! Use chacha20-crypt-bytes with raw byte keys (32 bytes) and nonces (12 bytes).

USING: arrays byte-arrays endian grouping kernel locals math
math.bitwise math.order sequences strings ;
IN: crypto.chacha20

<PRIVATE

!
! Constants
!

! ChaCha20 constants: ASCII encoding of "expand 32-byte k"
: constants ( -- seq )
    { 0x61707865 0x3320646e 0x79622d32 0x6b206574 } ;

!
! Byte Conversion
!

! Convert byte sequence to u32 array (little-endian)
: bytes>u32s ( bytes -- u32s )
    4 group [ le> ] map ;

! Convert state (16 u32s) to 64-byte keystream
: state>keystream ( state -- bytes )
    [ 4 >le ] map concat ;

!
! Core ChaCha20 Operations
!

! Quarter-round: the core mixing operation
! Performs 4 additions, 4 XORs, and 4 rotations (16, 12, 8, 7)
:: quarter-round ( a b c d -- a' b' c' d' )
    a b w+ :> w!
    d w bitxor 16 bitroll-32 :> z!
    c z w+ :> y!
    b y bitxor 12 bitroll-32 :> x!
    w x w+ w!
    z w bitxor 8 bitroll-32 z!
    y z w+ y!
    x y bitxor 7 bitroll-32 x!
    w x y z ;

! Initialize state from key, nonce, and counter
! Layout: constants(4) || key(8) || counter(1) || nonce(3) = 16 u32s
:: chacha20-init ( key nonce counter -- state )
    constants key append counter 1array append nonce append >array ;

! Apply quarter-round at specific state indices (mutates state)
:: apply-qround ( state a b c d -- state )
    a state nth
    b state nth
    c state nth
    d state nth
    quarter-round :> d' :> c' :> b' :> a'
    a' a state set-nth
    b' b state set-nth
    c' c state set-nth
    d' d state set-nth
    state ;

! Main block function: 20 rounds (10 double-rounds)
! Each double-round: 4 column rounds + 4 diagonal rounds
:: chacha20-block ( state -- state )
    10 [
        ! Column rounds
        state 0 4 8 12 apply-qround drop
        state 1 5 9 13 apply-qround drop
        state 2 6 10 14 apply-qround drop
        state 3 7 11 15 apply-qround drop
        ! Diagonal rounds
        state 0 5 10 15 apply-qround drop
        state 1 6 11 12 apply-qround drop
        state 2 7 8 13 apply-qround drop
        state 3 4 9 14 apply-qround drop
    ] times
    state ;

! Finalize: add initial state to working state (mod 2^32)
: chacha20-finalize ( working-state initial-state -- final-state )
    [ w+ ] 2map ;

! Generate one 64-byte keystream block
: chacha20-block-state ( key nonce counter -- final-state )
    chacha20-init dup clone chacha20-block swap chacha20-finalize ;

!
! Multi-block Support
!

! Split sequence into chunks of n (last chunk may be smaller)
: split-blocks ( seq n -- chunks )
    [ dup length 0 > ] swap [ over length min cut swap ] curry produce nip ;

PRIVATE>

!
! High-level API
!

! Encrypt or decrypt data of any length
! XOR is symmetric so same function works for both
:: chacha20-crypt ( data key nonce counter -- result )
    data 64 split-blocks
    [| block i |
        key nonce counter i + chacha20-block-state state>keystream
        block length head
        block [ bitxor ] 2map
    ] map-index concat ;

!
! Byte API
!

! Encrypt/decrypt with raw byte key (32 bytes) and nonce (12 bytes)
: chacha20-crypt-bytes ( data key-bytes nonce-bytes counter -- result )
    [ bytes>u32s ] 2dip [ bytes>u32s ] dip chacha20-crypt ;

!
! String Helpers
!

! Encrypt a string, returning ciphertext bytes
: chacha20-encrypt-string ( string key-bytes nonce-bytes counter -- ciphertext )
    [ >byte-array ] 3dip chacha20-crypt-bytes ;

! Decrypt ciphertext bytes to a string
: chacha20-decrypt-string ( ciphertext key-bytes nonce-bytes counter -- string )
    chacha20-crypt-bytes >string ;
