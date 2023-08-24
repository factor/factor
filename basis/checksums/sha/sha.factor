! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types checksums checksums.common
combinators combinators.smart endian grouping kernel
kernel.private literals math math.bitwise ranges
sequences sequences.generalizations sequences.private
specialized-arrays ;
SPECIALIZED-ARRAY: uint
SPECIALIZED-ARRAY: ulong
IN: checksums.sha

MIXIN: sha
INSTANCE: sha block-checksum

SINGLETON: sha1
INSTANCE: sha1 sha

SINGLETON: sha-224
SINGLETON: sha-256

INSTANCE: sha-224 sha
INSTANCE: sha-256 sha

<PRIVATE

TUPLE: sha1-state < block-checksum-state
{ K uint-array }
{ H uint-array }
{ W uint-array }
{ word-size fixnum } ;

CONSTANT: initial-H-sha1
    uint-array{
        0x67452301
        0xefcdab89
        0x98badcfe
        0x10325476
        0xc3d2e1f0
    }

CONSTANT: K-sha1
    $[
        20 0x5a827999 <repetition>
        20 0x6ed9eba1 <repetition>
        20 0x8f1bbcdc <repetition>
        20 0xca62c1d6 <repetition>
        4 uint-array{ } nappend-as
    ]

TUPLE: sha2-state < block-checksum-state
{ K uint-array }
{ H uint-array }
{ word-size fixnum } ;

TUPLE: sha2-short < sha2-state ;

TUPLE: sha2-long < sha2-state ;

TUPLE: sha-224-state < sha2-short ;

TUPLE: sha-256-state < sha2-short ;

M: sha2-state clone
    call-next-method
    [ clone ] change-H
    [ clone ] change-K ;

CONSTANT: a 0
CONSTANT: b 1
CONSTANT: c 2
CONSTANT: d 3
CONSTANT: e 4
CONSTANT: f 5
CONSTANT: g 6
CONSTANT: h 7

CONSTANT: initial-H-224
    uint-array{
        0xc1059ed8 0x367cd507 0x3070dd17 0xf70e5939
        0xffc00b31 0x68581511 0x64f98fa7 0xbefa4fa4
    }

CONSTANT: initial-H-256
    uint-array{
        0x6a09e667 0xbb67ae85 0x3c6ef372 0xa54ff53a
        0x510e527f 0x9b05688c 0x1f83d9ab 0x5be0cd19
    }

CONSTANT: initial-H-384
    ulong-array{
        0xcbbb9d5dc1059ed8
        0x629a292a367cd507
        0x9159015a3070dd17
        0x152fecd8f70e5939
        0x67332667ffc00b31
        0x8eb44a8768581511
        0xdb0c2e0d64f98fa7
        0x47b5481dbefa4fa4
    }

CONSTANT: initial-H-512
    ulong-array{
        0x6a09e667f3bcc908
        0xbb67ae8584caa73b
        0x3c6ef372fe94f82b
        0xa54ff53a5f1d36f1
        0x510e527fade682d1
        0x9b05688c2b3e6c1f
        0x1f83d9abfb41bd6b
        0x5be0cd19137e2179
    }

CONSTANT: K-256
    uint-array{
        0x428a2f98 0x71374491 0xb5c0fbcf 0xe9b5dba5
        0x3956c25b 0x59f111f1 0x923f82a4 0xab1c5ed5
        0xd807aa98 0x12835b01 0x243185be 0x550c7dc3
        0x72be5d74 0x80deb1fe 0x9bdc06a7 0xc19bf174
        0xe49b69c1 0xefbe4786 0x0fc19dc6 0x240ca1cc
        0x2de92c6f 0x4a7484aa 0x5cb0a9dc 0x76f988da
        0x983e5152 0xa831c66d 0xb00327c8 0xbf597fc7
        0xc6e00bf3 0xd5a79147 0x06ca6351 0x14292967
        0x27b70a85 0x2e1b2138 0x4d2c6dfc 0x53380d13
        0x650a7354 0x766a0abb 0x81c2c92e 0x92722c85
        0xa2bfe8a1 0xa81a664b 0xc24b8b70 0xc76c51a3
        0xd192e819 0xd6990624 0xf40e3585 0x106aa070
        0x19a4c116 0x1e376c08 0x2748774c 0x34b0bcb5
        0x391c0cb3 0x4ed8aa4a 0x5b9cca4f 0x682e6ff3
        0x748f82ee 0x78a5636f 0x84c87814 0x8cc70208
        0x90befffa 0xa4506ceb 0xbef9a3f7 0xc67178f2
    }

CONSTANT: K-384
    ulong-array{
        0x428a2f98d728ae22 0x7137449123ef65cd 0xb5c0fbcfec4d3b2f 0xe9b5dba58189dbbc
        0x3956c25bf348b538 0x59f111f1b605d019 0x923f82a4af194f9b 0xab1c5ed5da6d8118
        0xd807aa98a3030242 0x12835b0145706fbe 0x243185be4ee4b28c 0x550c7dc3d5ffb4e2
        0x72be5d74f27b896f 0x80deb1fe3b1696b1 0x9bdc06a725c71235 0xc19bf174cf692694
        0xe49b69c19ef14ad2 0xefbe4786384f25e3 0x0fc19dc68b8cd5b5 0x240ca1cc77ac9c65
        0x2de92c6f592b0275 0x4a7484aa6ea6e483 0x5cb0a9dcbd41fbd4 0x76f988da831153b5
        0x983e5152ee66dfab 0xa831c66d2db43210 0xb00327c898fb213f 0xbf597fc7beef0ee4
        0xc6e00bf33da88fc2 0xd5a79147930aa725 0x06ca6351e003826f 0x142929670a0e6e70
        0x27b70a8546d22ffc 0x2e1b21385c26c926 0x4d2c6dfc5ac42aed 0x53380d139d95b3df
        0x650a73548baf63de 0x766a0abb3c77b2a8 0x81c2c92e47edaee6 0x92722c851482353b
        0xa2bfe8a14cf10364 0xa81a664bbc423001 0xc24b8b70d0f89791 0xc76c51a30654be30
        0xd192e819d6ef5218 0xd69906245565a910 0xf40e35855771202a 0x106aa07032bbd1b8
        0x19a4c116b8d2d0c8 0x1e376c085141ab53 0x2748774cdf8eeb99 0x34b0bcb5e19b48a8
        0x391c0cb3c5c95a63 0x4ed8aa4ae3418acb 0x5b9cca4f7763e373 0x682e6ff3d6b2b8a3
        0x748f82ee5defb2fc 0x78a5636f43172f60 0x84c87814a1f0ab72 0x8cc702081a6439ec
        0x90befffa23631e28 0xa4506cebde82bde9 0xbef9a3f7b2c67915 0xc67178f2e372532b
        0xca273eceea26619c 0xd186b8c721c0c207 0xeada7dd6cde0eb1e 0xf57d4f7fee6ed178
        0x06f067aa72176fba 0x0a637dc5a2c898a6 0x113f9804bef90dae 0x1b710b35131c471b
        0x28db77f523047d84 0x32caab7b40c72493 0x3c9ebe0a15c9bebc 0x431d67c49c100d4c
        0x4cc5d4becb3e42b6 0x597f299cfc657e2a 0x5fcb6fab3ad6faec 0x6c44198c4a475817
    }

ALIAS: K-512 K-384

: <sha1-state> ( -- sha1-state )
    sha1-state new-checksum-state
        64 >>block-size
        K-sha1 >>K
        initial-H-sha1 >>H
        4 >>word-size ;

: <sha-224-state> ( -- sha2-state )
    sha-224-state new-checksum-state
        64 >>block-size
        K-256 >>K
        initial-H-224 >>H
        4 >>word-size ;

: <sha-256-state> ( -- sha2-state )
    sha-256-state new-checksum-state
        64 >>block-size
        K-256 >>K
        initial-H-256 >>H
        4 >>word-size ;

M: sha1 initialize-checksum-state drop <sha1-state> ;

M: sha-224 initialize-checksum-state drop <sha-224-state> ;

M: sha-256 initialize-checksum-state drop <sha-256-state> ;

: s0-256 ( x -- x' )
    [
        [ -7 bitroll-32 ]
        [ -18 bitroll-32 ]
        [ -3 shift ] tri
    ] [ bitxor ] reduce-outputs ; inline

: s1-256 ( x -- x' )
    [
        [ -17 bitroll-32 ]
        [ -19 bitroll-32 ]
        [ -10 shift ] tri
    ] [ bitxor ] reduce-outputs ; inline

: S0-256 ( x -- x' )
    [
        [ -2 bitroll-32 ]
        [ -13 bitroll-32 ]
        [ -22 bitroll-32 ] tri
    ] [ bitxor ] reduce-outputs ; inline

: S1-256 ( x -- x' )
    [
        [ -6 bitroll-32 ]
        [ -11 bitroll-32 ]
        [ -25 bitroll-32 ] tri
    ] [ bitxor ] reduce-outputs ; inline

: s0-512 ( x -- x' )
    [
        [ -1 bitroll-64 ]
        [ -8 bitroll-64 ]
        [ -7 shift ] tri
    ] [ bitxor ] reduce-outputs ; inline

: s1-512 ( x -- x' )
    [
        [ -19 bitroll-64 ]
        [ -61 bitroll-64 ]
        [ -6 shift ] tri
    ] [ bitxor ] reduce-outputs ; inline

: S0-512 ( x -- x' )
    [
        [ -28 bitroll-64 ]
        [ -34 bitroll-64 ]
        [ -39 bitroll-64 ] tri
    ] [ bitxor ] reduce-outputs ; inline

: S1-512 ( x -- x' )
    [
        [ -14 bitroll-64 ]
        [ -18 bitroll-64 ]
        [ -41 bitroll-64 ] tri
    ] [ bitxor ] reduce-outputs ; inline

: prepare-M-256 ( n seq -- )
    { uint-array } declare
    {
        [ [ 16 - ] dip nth-unsafe ]
        [ [ 15 - ] dip nth-unsafe s0-256 ]
        [ [ 7 - ] dip nth-unsafe ]
        [ [ 2 - ] dip nth-unsafe s1-256 w+ w+ w+ ]
        [ ]
    } 2cleave set-nth-unsafe ; inline

: prepare-M-512 ( n seq -- )
    { ulong-array } declare
    {
        [ [ 16 - ] dip nth-unsafe ]
        [ [ 15 - ] dip nth-unsafe s0-512 ]
        [ [ 7 - ] dip nth-unsafe ]
        [ [ 2 - ] dip nth-unsafe s1-512 w+ w+ w+ ]
        [ ]
    } 2cleave set-nth-unsafe ; inline

: ch ( x y z -- x' )
    [ bitxor bitand ] keep bitxor ; inline

: maj ( x y z -- x' )
    [ [ bitand ] [ bitor ] 2bi ] dip bitand bitor ; inline

: slice3 ( n seq -- a b c )
    [ dup 3 + ] dip <slice> first3 ; inline

GENERIC: pad-initial-bytes ( string sha2 -- padded-string )

:: T1-256 ( n M H sha2 -- T1 )
    n M nth-unsafe
    n sha2 K>> nth-unsafe +
    e H slice3 ch w+
    e H nth-unsafe S1-256 w+
    h H nth-unsafe w+ ; inline

:: T2-256 ( H -- T2 )
    a H nth-unsafe S0-256
    a H slice3 maj w+ ; inline

:: T1-512 ( n M H sha2 -- T1 )
    n M nth-unsafe
    n sha2 K>> nth-unsafe +
    e H slice3 ch w+
    e H nth-unsafe S1-512 w+
    h H nth-unsafe w+ ; inline

:: T2-512 ( H -- T2 )
    a H nth-unsafe S0-512
    a H slice3 maj w+ ; inline

:: update-H ( T1 T2 H -- )
    h g H exchange-unsafe
    g f H exchange-unsafe
    f e H exchange-unsafe
    T1 d H nth-unsafe w+ e H set-nth-unsafe
    d c H exchange-unsafe
    c b H exchange-unsafe
    b a H exchange-unsafe
    T1 T2 w+ a H set-nth-unsafe ; inline

: prepare-message-schedule ( seq sha2 -- w-seq )
    [ word-size>> <groups> ] [ block-size>> <uint-array> ] bi
    [ '[ [ be> ] dip _ set-nth-unsafe ] each-index ]
    [ 16 over length [a..b) over '[ _ prepare-M-256 ] each ] bi ; inline

:: process-chunk ( M block-size cloned-H sha2 -- )
    block-size [
        M cloned-H sha2 T1-256
        cloned-H T2-256
        cloned-H update-H
    ] each-integer
    sha2 [ cloned-H [ w+ ] 2map ] change-H drop ; inline

M: sha2-short checksum-block
    [ prepare-message-schedule ]
    [ [ block-size>> ] [ H>> clone ] [ ] tri process-chunk ] bi ;

: sequence>byte-array ( seq n -- bytes )
    '[ _ >be ] { } map-as B{ } concat-as ; inline

: sha1>checksum ( sha2 -- bytes )
    H>> 4 sequence>byte-array ; inline

: sha-224>checksum ( sha2 -- bytes )
    H>> 7 head 4 sequence>byte-array ; inline

: sha-256>checksum ( sha2 -- bytes )
    H>> 4 sequence>byte-array ; inline

: pad-last-short-block ( state -- )
    [ bytes>> t ] [ bytes-read>> pad-last-block ] [ ] tri
    [ checksum-block ] curry each ; inline

M: sha-224-state get-checksum
    clone
    [ pad-last-short-block ] [ sha-224>checksum ] bi ;

M: sha-256-state get-checksum
    clone
    [ pad-last-short-block ] [ sha-256>checksum ] bi ;

: sha1-W ( t seq -- )
    { uint-array } declare
    {
        [ [ 3 - ] dip nth-unsafe ]
        [ [ 8 - ] dip nth-unsafe bitxor ]
        [ [ 14 - ] dip nth-unsafe bitxor ]
        [ [ 16 - ] dip nth-unsafe bitxor 1 bitroll-32 ]
        [ ]
    } 2cleave set-nth-unsafe ; inline

: prepare-sha1-message-schedule ( seq -- w-seq )
    4 <groups> 80 <uint-array>
    [ '[ [ be> ] dip _ set-nth-unsafe ] each-index ]
    [ 16 80 [a..b) over '[ _ sha1-W ] each ] bi ; inline

: sha1-f ( B C D n -- f_nbcd )
    20 /i
    {
        { 0 [ [ over bitnot ] dip bitand [ bitand ] dip bitor ] }
        { 1 [ bitxor bitxor ] }
        { 2 [ 2dup bitand [ pick bitand [ bitand ] dip ] dip bitor bitor ] }
        { 3 [ bitxor bitxor ] }
    } case ; inline

:: inner-loop ( n H W K -- temp )
    a H nth-unsafe :> A
    b H nth-unsafe :> B
    c H nth-unsafe :> C
    d H nth-unsafe :> D
    e H nth-unsafe :> E
    [
        A 5 bitroll-32

        B C D n sha1-f

        E

        n K nth-unsafe

        n W nth-unsafe
    ] sum-outputs 32 bits ; inline

:: process-sha1-chunk ( H W K state -- )
    80 [
        H W K inner-loop
        d H nth-unsafe e H set-nth-unsafe
        c H nth-unsafe d H set-nth-unsafe
        b H nth-unsafe 30 bitroll-32 c H set-nth-unsafe
        a H nth-unsafe b H set-nth-unsafe
        a H set-nth-unsafe
    ] each-integer
    state [ H [ w+ ] 2map ] change-H drop ; inline

M:: sha1-state checksum-block ( bytes state -- )
    bytes prepare-sha1-message-schedule state W<<

    state [ H>> clone ] [ W>> ] [ K>> ] tri state process-sha1-chunk ;

M: sha1-state get-checksum
    clone
    [ pad-last-short-block ] [ sha-256>checksum ] bi ;

PRIVATE>
