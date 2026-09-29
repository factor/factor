! Copyright (C) 2026 Zoltán Kéri <z@zolk3ri.name>
! See https://factorcode.org/license.txt for BSD license.
!
! Poly1305 message authentication code (RFC 8439)
!
! Key: 32 bytes (r: 16 bytes, s: 16 bytes)
! Message: arbitrary length byte sequence
! Tag: 16 bytes (128-bit authenticator)
!
! Byte order: little-endian throughout.
!
! Timing: poly1305-verify compares tags in constant time, but the
! bignum arithmetic is not constant-time, so computing a tag can
! leak timing information about the key (RFC 8439 Sections 3, 4).
!
! Example:
!   "Hello" >byte-array
!   B{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
!      17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 }
!   poly1305-mac
!   ! => B{ 205 107 36 196 87 50 35 27 200 16 3 251 167 240 226 90 }

USING: byte-arrays crypto.utils endian grouping kernel locals
math sequences ;
IN: crypto.poly1305

<PRIVATE

!
! Constants
!

! Prime P = 2^130 - 5
: poly1305-prime ( -- p )
    130 2^ 5 - ;

!
! Byte Conversion
!

! Serialize the low 128 bits of n as a 16-byte little-endian tag.
! RFC 8439 keeps "the 128 least significant bits" of acc + s, and
! acc + s can exceed 2^128 because acc can be as large as 2^130-6.
: num>tag ( n -- bytes )
    128 2^ 1 - bitand 16 >le ;

!
! Key Processing
!

! Clamp r per RFC 8439 Section 2.5: clear the top 4 bits of bytes
! 3, 7, 11, 15 and the bottom 2 bits of bytes 4, 8, 12
: clamp-r ( r -- r' )
    0x0ffffffc0ffffffc0ffffffc0fffffff bitand ;

! Split 32-byte key into (r, s) pair
! r = first 16 bytes (clamped), s = last 16 bytes
: split-key ( key -- r s )
    [ 16 head le> clamp-r ] [ 16 tail le> ] bi ;

!
! Core Poly1305 Operations
!

! Read a block as a little-endian number and add one bit beyond its
! last byte, i.e. 2^(8*n) for an n-byte block (RFC 8439 Section 2.5)
: block>num ( block -- n )
    B{ 0x01 } append le> ;

! Poly1305 accumulator update: acc = ((acc + block) * r) mod p
:: poly1305-accumulate ( acc block r p -- acc' )
    acc block block>num + r * p mod ;

! Process the message in 16-byte blocks; the last may be shorter.
! Verified erratum 5689 fixes an off-by-one in the block slice of
! the RFC 8439 Section 2.5.1 pseudocode, and 16 group matches the
! corrected version.
:: poly1305-process ( message r p -- acc )
    0 :> acc!
    message 16 group [| block |
        acc block r p poly1305-accumulate acc!
    ] each
    acc ;

PRIVATE>

!
! High-level API
!

! Compute Poly1305 MAC tag for message with 32-byte key
! Returns 16-byte authentication tag
:: poly1305-mac ( message key -- tag )
    key split-key :> s :> r
    poly1305-prime :> p
    message r p poly1305-process s + num>tag ;

!
! Verification API
!

! Verify a Poly1305 tag; the comparison is constant-time
! Returns t if the tag matches, f otherwise (including when the
! expected tag has the wrong length)
: poly1305-verify ( message key expected-tag -- ? )
    [ poly1305-mac ] dip constant-time= ;
