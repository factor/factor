USING: crypto.common kernel splitting math sequences namespaces
io.binary ;
IN: crypto.sha2

<PRIVATE

SYMBOL: vars
SYMBOL: M
SYMBOL: K
SYMBOL: H
SYMBOL: S0
SYMBOL: S1
SYMBOL: process-M
SYMBOL: word-size
SYMBOL: block-size
SYMBOL: >word

: a 0 ;
: b 1 ;
: c 2 ;
: d 3 ;
: e 4 ;
: f 5 ;
: g 6 ;
: h 7 ;

: initial-H-256 ( -- seq )
    {
        HEX: 6a09e667 HEX: bb67ae85 HEX: 3c6ef372 HEX: a54ff53a
        HEX: 510e527f HEX: 9b05688c HEX: 1f83d9ab HEX: 5be0cd19
    } ;

: K-256 ( -- seq )
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
    } ;

: s0-256 ( x -- x' )
    [ -7 bitroll-32 ] keep
    [ -18 bitroll-32 ] keep
    -3 shift bitxor bitxor ; inline

: s1-256 ( x -- x' )
    [ -17 bitroll-32 ] keep
    [ -19 bitroll-32 ] keep
    -10 shift bitxor bitxor ; inline

: process-M-256 ( seq n -- )
    [ 16 - swap nth ] 2keep
    [ 15 - swap nth s0-256 ] 2keep
    [ 7 - swap nth ] 2keep
    [ 2 - swap nth s1-256 ] 2keep
    >r >r + + w+ r> r> swap set-nth ; inline

: prepare-message-schedule ( seq -- w-seq )
    word-size get group [ be> ] map block-size get 0 pad-right
    dup 16 64 dup <slice> [
        process-M-256
    ] curry* each ;

: ch ( x y z -- x' )
    [ bitxor bitand ] keep bitxor ;

: maj ( x y z -- x' )
    >r [ bitand ] 2keep bitor r> bitand bitor ;

: S0-256 ( x -- x' )
    [ -2 bitroll-32 ] keep
    [ -13 bitroll-32 ] keep
    -22 bitroll-32 bitxor bitxor ; inline

: S1-256 ( x -- x' )
    [ -6 bitroll-32 ] keep
    [ -11 bitroll-32 ] keep
    -25 bitroll-32 bitxor bitxor ; inline

: T1 ( W n -- T1 )
    [ swap nth ] keep
    K get nth +
    e vars get slice3 ch +
    e vars get nth S1-256 +
    h vars get nth w+ ;

: T2 ( -- T2 )
    a vars get nth S0-256
    a vars get slice3 maj w+ ;

: update-vars ( T1 T2 -- )
    vars get
    h g pick exchange
    g f pick exchange
    f e pick exchange
    pick d pick nth w+ e pick set-nth
    d c pick exchange
    c b pick exchange
    b a pick exchange
    >r w+ a r> set-nth ;

: process-chunk ( M -- )
    H get clone vars set
    prepare-message-schedule block-size get [
        T1 T2 update-vars
    ] curry* each vars get H get [ w+ ] 2map H set ;

: seq>string ( n seq -- string )
    [ swap [ >be % ] curry each ] "" make ;

: string>sha2 ( string -- string )
    t preprocess-plaintext
    block-size get group [ process-chunk ] each
    4 H get seq>string ;

PRIVATE>

: string>sha-256 ( string -- string )
    [
        K-256 K set
        initial-H-256 H set
        4 word-size set
        64 block-size set
        \ >32-bit >word set
        string>sha2
    ] with-scope ;

: string>sha-256-string ( string -- hexstring )
    string>sha-256 hex-string ;

