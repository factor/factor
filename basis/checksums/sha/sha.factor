! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors checksums checksums.common checksums.stream
combinators combinators.smart fry generalizations grouping
io.binary kernel literals locals make math math.bitwise
math.ranges multiline namespaces sbufs sequences
sequences.private splitting strings ;
IN: checksums.sha

SINGLETON: sha1
INSTANCE: sha1 stream-checksum

SINGLETON: sha-224
SINGLETON: sha-256

INSTANCE: sha-224 stream-checksum
INSTANCE: sha-256 stream-checksum

TUPLE: sha1-state < checksum-state K H W word-size ;

CONSTANT: initial-H-sha1
    { 
        HEX: 67452301
        HEX: efcdab89
        HEX: 98badcfe
        HEX: 10325476
        HEX: c3d2e1f0
    }

CONSTANT: K-sha1
    $[
        20 HEX: 5a827999 <repetition>
        20 HEX: 6ed9eba1 <repetition>
        20 HEX: 8f1bbcdc <repetition>
        20 HEX: ca62c1d6 <repetition> 
        4 { } nappend-as
    ]

TUPLE: sha2-state < checksum-state K H word-size ;

TUPLE: sha2-short < sha2-state ;

TUPLE: sha2-long < sha2-state ;

TUPLE: sha-224-state < sha2-short ;

TUPLE: sha-256-state < sha2-short ;

M: sha2-state clone
    call-next-method
    [ clone ] change-H
    [ clone ] change-K ;

<PRIVATE

CONSTANT: a 0
CONSTANT: b 1
CONSTANT: c 2
CONSTANT: d 3
CONSTANT: e 4
CONSTANT: f 5
CONSTANT: g 6
CONSTANT: h 7

CONSTANT: initial-H-224
    {
        HEX: c1059ed8 HEX: 367cd507 HEX: 3070dd17 HEX: f70e5939
        HEX: ffc00b31 HEX: 68581511 HEX: 64f98fa7 HEX: befa4fa4
    }

CONSTANT: initial-H-256
    {
        HEX: 6a09e667 HEX: bb67ae85 HEX: 3c6ef372 HEX: a54ff53a
        HEX: 510e527f HEX: 9b05688c HEX: 1f83d9ab HEX: 5be0cd19
    }

CONSTANT: initial-H-384
    {
        HEX: cbbb9d5dc1059ed8
        HEX: 629a292a367cd507
        HEX: 9159015a3070dd17
        HEX: 152fecd8f70e5939
        HEX: 67332667ffc00b31
        HEX: 8eb44a8768581511
        HEX: db0c2e0d64f98fa7
        HEX: 47b5481dbefa4fa4
    }

CONSTANT: initial-H-512
    {
        HEX: 6a09e667f3bcc908
        HEX: bb67ae8584caa73b
        HEX: 3c6ef372fe94f82b
        HEX: a54ff53a5f1d36f1
        HEX: 510e527fade682d1
        HEX: 9b05688c2b3e6c1f
        HEX: 1f83d9abfb41bd6b
        HEX: 5be0cd19137e2179
    }

CONSTANT: K-256
    {
        HEX: 428a2f98 HEX: 71374491 HEX: b5c0fbcf HEX: e9b5dba5
        HEX: 3956c25b HEX: 59f111f1 HEX: 923f82a4 HEX: ab1c5ed5
        HEX: d807aa98 HEX: 12835b01 HEX: 243185be HEX: 550c7dc3
        HEX: 72be5d74 HEX: 80deb1fe HEX: 9bdc06a7 HEX: c19bf174
        HEX: e49b69c1 HEX: efbe4786 HEX: 0fc19dc6 HEX: 240ca1cc
        HEX: 2de92c6f HEX: 4a7484aa HEX: 5cb0a9dc HEX: 76f988da
        HEX: 983e5152 HEX: a831c66d HEX: b00327c8 HEX: bf597fc7
        HEX: c6e00bf3 HEX: d5a79147 HEX: 06ca6351 HEX: 14292967
        HEX: 27b70a85 HEX: 2e1b2138 HEX: 4d2c6dfc HEX: 53380d13
        HEX: 650a7354 HEX: 766a0abb HEX: 81c2c92e HEX: 92722c85
        HEX: a2bfe8a1 HEX: a81a664b HEX: c24b8b70 HEX: c76c51a3
        HEX: d192e819 HEX: d6990624 HEX: f40e3585 HEX: 106aa070
        HEX: 19a4c116 HEX: 1e376c08 HEX: 2748774c HEX: 34b0bcb5
        HEX: 391c0cb3 HEX: 4ed8aa4a HEX: 5b9cca4f HEX: 682e6ff3
        HEX: 748f82ee HEX: 78a5636f HEX: 84c87814 HEX: 8cc70208
        HEX: 90befffa HEX: a4506ceb HEX: bef9a3f7 HEX: c67178f2
    }

CONSTANT: K-384
    {

        HEX: 428a2f98d728ae22 HEX: 7137449123ef65cd HEX: b5c0fbcfec4d3b2f HEX: e9b5dba58189dbbc 
        HEX: 3956c25bf348b538 HEX: 59f111f1b605d019 HEX: 923f82a4af194f9b HEX: ab1c5ed5da6d8118 
        HEX: d807aa98a3030242 HEX: 12835b0145706fbe HEX: 243185be4ee4b28c HEX: 550c7dc3d5ffb4e2
        HEX: 72be5d74f27b896f HEX: 80deb1fe3b1696b1 HEX: 9bdc06a725c71235 HEX: c19bf174cf692694 
        HEX: e49b69c19ef14ad2 HEX: efbe4786384f25e3 HEX: 0fc19dc68b8cd5b5 HEX: 240ca1cc77ac9c65 
        HEX: 2de92c6f592b0275 HEX: 4a7484aa6ea6e483 HEX: 5cb0a9dcbd41fbd4 HEX: 76f988da831153b5 
        HEX: 983e5152ee66dfab HEX: a831c66d2db43210 HEX: b00327c898fb213f HEX: bf597fc7beef0ee4 
        HEX: c6e00bf33da88fc2 HEX: d5a79147930aa725 HEX: 06ca6351e003826f HEX: 142929670a0e6e70 
        HEX: 27b70a8546d22ffc HEX: 2e1b21385c26c926 HEX: 4d2c6dfc5ac42aed HEX: 53380d139d95b3df 
        HEX: 650a73548baf63de HEX: 766a0abb3c77b2a8 HEX: 81c2c92e47edaee6 HEX: 92722c851482353b 
        HEX: a2bfe8a14cf10364 HEX: a81a664bbc423001 HEX: c24b8b70d0f89791 HEX: c76c51a30654be30 
        HEX: d192e819d6ef5218 HEX: d69906245565a910 HEX: f40e35855771202a HEX: 106aa07032bbd1b8 
        HEX: 19a4c116b8d2d0c8 HEX: 1e376c085141ab53 HEX: 2748774cdf8eeb99 HEX: 34b0bcb5e19b48a8 
        HEX: 391c0cb3c5c95a63 HEX: 4ed8aa4ae3418acb HEX: 5b9cca4f7763e373 HEX: 682e6ff3d6b2b8a3 
        HEX: 748f82ee5defb2fc HEX: 78a5636f43172f60 HEX: 84c87814a1f0ab72 HEX: 8cc702081a6439ec 
        HEX: 90befffa23631e28 HEX: a4506cebde82bde9 HEX: bef9a3f7b2c67915 HEX: c67178f2e372532b 
        HEX: ca273eceea26619c HEX: d186b8c721c0c207 HEX: eada7dd6cde0eb1e HEX: f57d4f7fee6ed178 
        HEX: 06f067aa72176fba HEX: 0a637dc5a2c898a6 HEX: 113f9804bef90dae HEX: 1b710b35131c471b 
        HEX: 28db77f523047d84 HEX: 32caab7b40c72493 HEX: 3c9ebe0a15c9bebc HEX: 431d67c49c100d4c 
        HEX: 4cc5d4becb3e42b6 HEX: 597f299cfc657e2a HEX: 5fcb6fab3ad6faec HEX: 6c44198c4a475817
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
    {
        [ [ 16 - ] dip nth-unsafe ]
        [ [ 15 - ] dip nth-unsafe s0-256 ]
        [ [ 7 - ] dip nth-unsafe ]
        [ [ 2 - ] dip nth-unsafe s1-256 w+ w+ w+ ]
        [ ]
    } 2cleave set-nth-unsafe ; inline

: prepare-M-512 ( n seq -- )
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

: T2-256 ( H -- T2 )
    [ a swap nth-unsafe S0-256 ]
    [ a swap slice3 maj w+ ] bi ; inline

:: T1-512 ( n M H sha2 -- T1 )
    n M nth-unsafe
    n sha2 K>> nth-unsafe +
    e H slice3 ch w+
    e H nth-unsafe S1-512 w+
    h H nth-unsafe w+ ; inline

: T2-512 ( H -- T2 )
    [ a swap nth-unsafe S0-512 ]
    [ a swap slice3 maj w+ ] bi ; inline

: update-H ( T1 T2 H -- )
    h g pick exchange-unsafe
    g f pick exchange-unsafe
    f e pick exchange-unsafe
    pick d pick nth-unsafe w+ e pick set-nth-unsafe
    d c pick exchange-unsafe
    c b pick exchange-unsafe
    b a pick exchange-unsafe
    [ w+ a ] dip set-nth-unsafe ; inline

: prepare-message-schedule ( seq sha2 -- w-seq )
    [ word-size>> <sliced-groups> [ be> ] map ]
    [
        block-size>> [ 0 pad-tail 16 ] keep [a,b) over
        '[ _ prepare-M-256 ] each
    ] bi ; inline

:: process-chunk ( M block-size cloned-H sha2 -- )
    block-size [
        M cloned-H sha2 T1-256
        cloned-H T2-256
        cloned-H update-H
    ] each
    sha2 [ cloned-H [ w+ ] 2map ] change-H drop ; inline

M: sha2-short checksum-block
    [ prepare-message-schedule ]
    [ [ block-size>> ] [ H>> clone ] [ ] tri process-chunk ] bi ;

: seq>byte-array ( seq n -- string )
    '[ _ >be ] map B{ } concat-as ;

: sha1>checksum ( sha2 -- bytes )
    H>> 4 seq>byte-array ;

: sha-224>checksum ( sha2 -- bytes )
    H>> 7 head 4 seq>byte-array ;

: sha-256>checksum ( sha2 -- bytes )
    H>> 4 seq>byte-array ;

: pad-last-short-block ( state -- )
    [ bytes>> t ] [ bytes-read>> pad-last-block ] [ ] tri
    [ checksum-block ] curry each ;

PRIVATE>

M: sha-224-state get-checksum
    clone
    [ pad-last-short-block ] [ sha-224>checksum ] bi ;

M: sha-256-state get-checksum
    clone
    [ pad-last-short-block ] [ sha-256>checksum ] bi ;

M: sha-224 checksum-stream ( stream checksum -- byte-array )
    drop
    [ <sha-224-state> ] dip add-checksum-stream get-checksum ;

M: sha-256 checksum-stream ( stream checksum -- byte-array )
    drop
    [ <sha-256-state> ] dip add-checksum-stream get-checksum ;

: sha1-W ( t seq -- )
    {
        [ [ 3 - ] dip nth-unsafe ]
        [ [ 8 - ] dip nth-unsafe bitxor ]
        [ [ 14 - ] dip nth-unsafe bitxor ]
        [ [ 16 - ] dip nth-unsafe bitxor 1 bitroll-32 ]
        [ ]
    } 2cleave set-nth-unsafe ;

: prepare-sha1-message-schedule ( seq -- w-seq )
    4 <sliced-groups> [ be> ] map
    80 0 pad-tail 16 80 [a,b) over
    '[ _ sha1-W ] each ; inline

: sha1-f ( B C D n -- f_nbcd )
    20 /i
    {
        { 0 [ [ over bitnot ] dip bitand [ bitand ] dip bitor ] }
        { 1 [ bitxor bitxor ] }
        { 2 [ 2dup bitand [ pick bitand [ bitand ] dip ] dip bitor bitor ] }
        { 3 [ bitxor bitxor ] }
    } case ;

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
    ] sum-outputs 32 bits ;

:: process-sha1-chunk ( bytes H W K state -- )
    80 [
        H W K inner-loop
        d H nth-unsafe e H set-nth-unsafe
        c H nth-unsafe d H set-nth-unsafe
        b H nth-unsafe 30 bitroll-32 c H set-nth-unsafe
        a H nth-unsafe b H set-nth-unsafe
        a H set-nth-unsafe
    ] each
    state [ H [ w+ ] 2map ] change-H drop ; inline

M:: sha1-state checksum-block ( bytes state -- )
    bytes prepare-sha1-message-schedule state (>>W)

    bytes
    state [ H>> clone ] [ W>> ] [ K>> ] tri state process-sha1-chunk ;

M: sha1-state get-checksum
    clone
    [ pad-last-short-block ] [ sha-256>checksum ] bi ;

M: sha1 checksum-stream ( stream checksum -- byte-array )
    drop
    [ <sha1-state> ] dip add-checksum-stream get-checksum ;
