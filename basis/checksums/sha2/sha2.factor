! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel splitting grouping math sequences namespaces make
io.binary math.bitwise checksums checksums.common
sbufs strings combinators.smart math.ranges fry combinators
accessors ;
IN: checksums.sha2

<PRIVATE

SYMBOL: sha2

CONSTANT: a 0
CONSTANT: b 1
CONSTANT: c 2
CONSTANT: d 3
CONSTANT: e 4
CONSTANT: f 5
CONSTANT: g 6
CONSTANT: h 7

CONSTANT: initial-H-256
    {
        HEX: 6a09e667 HEX: bb67ae85 HEX: 3c6ef372 HEX: a54ff53a
        HEX: 510e527f HEX: 9b05688c HEX: 1f83d9ab HEX: 5be0cd19
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

: process-M-256 ( n seq -- )
    {
        [ [ 16 - ] dip nth ]
        [ [ 15 - ] dip nth s0-256 ]
        [ [ 7 - ] dip nth ]
        [ [ 2 - ] dip nth s1-256 w+ w+ w+ ]
        [ ]
    } 2cleave set-nth ; inline

: ch ( x y z -- x' )
    [ bitxor bitand ] keep bitxor ;

: maj ( x y z -- x' )
    [ [ bitand ] [ bitor ] 2bi ] dip bitand bitor ;

: prepare-message-schedule ( seq -- w-seq )
    sha2 get word-size>> <sliced-groups> [ be> ] map sha2 get block-size>> 0 pad-tail
    16 64 [a,b) over '[ _ process-M-256 ] each ;

: slice3 ( n seq -- a b c )
    [ dup 3 + ] dip <slice> first3 ; inline

: T1 ( W n H -- T1 )
    [
        [ swap nth ] keep
        sha2 get K>> nth +
    ] dip
    [ e swap slice3 ch w+ ]
    [ e swap nth S1-256 w+ ]
    [ h swap nth w+ ] tri ;

: T2 ( H -- T2 )
    [ a swap nth S0-256 ]
    [ a swap slice3 maj w+ ] bi ;

: update-H ( T1 T2 H -- )
    h g pick exchange
    g f pick exchange
    f e pick exchange
    pick d pick nth w+ e pick set-nth
    d c pick exchange
    c b pick exchange
    b a pick exchange
    [ w+ a ] dip set-nth ;

: process-chunk ( M block-size H-cloned -- )
    [
        '[
            _
            [ T1 ]
            [ T2 ]
            [ update-H ] tri 
        ] with each
    ] keep sha2 get H>> [ w+ ] 2map sha2 get (>>H) ;

: pad-initial-bytes ( string -- padded-string )
    dup [
        HEX: 80 ,
        length 
        [ HEX: 3f bitand calculate-pad-length 0 <string> % ]
        [ 3 shift 8 >be % ] bi
    ] "" make append ;

: seq>byte-array ( seq n -- string )
    '[ _ >be ] map B{ } join ;

: byte-array>sha2 ( byte-array -- string )
    pad-initial-bytes
    sha2 get block-size>> <sliced-groups>
    [
        prepare-message-schedule
        sha2 get [ block-size>> ] [ H>> clone ] bi process-chunk
    ] each
    sha2 get H>> 4 seq>byte-array ;

PRIVATE>

SINGLETON: sha-256

INSTANCE: sha-256 checksum

TUPLE: sha2-state K H word-size block-size ;

TUPLE: sha-256-state < sha2-state ;

: <sha-256-state> ( -- sha2-state )
    sha-256-state new
        K-256 >>K
        initial-H-256 >>H
        4 >>word-size
        64 >>block-size ; 

M: sha-256 checksum-bytes
    drop
    <sha-256-state> sha2 [
        byte-array>sha2
    ] with-variable ;
