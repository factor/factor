IN: crypto-internals
USING: kernel io strings sequences namespaces math prettyprint
unparser test parser lists vectors hashtables kernel-internals crypto ;

! Implemented according to RFC 3174.

SYMBOL: h0
SYMBOL: h1
SYMBOL: h2
SYMBOL: h3
SYMBOL: h4
SYMBOL: A
SYMBOL: B
SYMBOL: C
SYMBOL: D
SYMBOL: E
SYMBOL: w
SYMBOL: K

: reset-w ( -- )
    80 <vector> w set ;

: initialize-sha1 ( -- )
    HEX: 67452301 dup h0 set A set
    HEX: efcdab89 dup h1 set B set
    HEX: 98badcfe dup h2 set C set
    HEX: 10325476 dup h3 set D set
    HEX: c3d2e1f0 dup h4 set E set
    reset-w
    [
        20 [ HEX: 5a827999 , ] times
        20 [ HEX: 6ed9eba1 , ] times
        20 [ HEX: 8f1bbcdc , ] times
        20 [ HEX: ca62c1d6 , ] times
    ] { } make K set ;

: get-wth ( n -- wth )
    w get nth ;

: shift-wth ( n -- )
    get-wth 1 32 bitroll ;

! W(t) = S^1(W(t-3) XOR W(t-8) XOR W(t-14) XOR W(t-16))
: sha1-W ( t -- W_t )
     dup 3 - get-wth
     over 8 - get-wth bitxor
     over 14 - get-wth bitxor
     swap 16 - get-wth bitxor 1 32 bitroll ;

! f(t;B,C,D) = (B AND C) OR ((NOT B) AND D)         ( 0 <= t <= 19)
! f(t;B,C,D) = B XOR C XOR D                        (20 <= t <= 39)
! f(t;B,C,D) = (B AND C) OR (B AND D) OR (C AND D)  (40 <= t <= 59)
! f(t;B,C,D) = B XOR C XOR D                        (60 <= t <= 79)

! use this syntax eventually
! JUMP-TABLE: f 4 ( maximum )
! H{
    ! { 0 [ >r over bitnot r> bitand >r bitand r> bitor ] }
    ! { 1 [ bitxor bitxor ] }
    ! { 2 [ 2dup bitand >r pick bitand >r bitand r> r> bitor bitor ] }
    ! { 3 [ bitxor bitxor ] }
! } f-table set

! J: 0 f >r over bitnot r> bitand >r bitand r> bitor ;
! J: 1 f bitxor bitxor ;
! J: 2 f 2dup bitand >r pick bitand >r bitand r> r> bitor bitor ;
! J: 3 f bitxor bitxor ;

: sha1-f ( B C D t -- f_tbcd )
    20 /i
    {   
        { [ dup 0 = ] [ drop >r over bitnot r> bitand >r bitand r> bitor ] }
        { [ dup 1 = ] [ drop bitxor bitxor ] }
        { [ dup 2 = ] [ drop 2dup bitand >r pick bitand >r bitand r> r> bitor bitor ] }
        { [ dup 3 = ] [ drop bitxor bitxor ] }
    } cond ;

: make-w ( -- )
    ! compute w, steps a-b of RFC 3174, section 6.1
    80 [ dup 16 < [
            [ nth-int-be w get push ] 2keep
        ] [
            dup sha1-W w get push
        ] if 
    ] repeat ;

: init-letters ( -- )
    ! step c of RFC 3174, section 6.1
    h0 get A set
    h1 get B set
    h2 get C set
    h3 get D set
    h4 get E set ;

: inner-loop ( -- )
    ! TEMP = S^5(A) + f(t;B,C,D) + E + W(t) + K(t);
    [
        [ B get C get D get ] keep sha1-f ,
        dup get-wth ,
        dup K get nth ,
        A get 5 32 bitroll ,
        E get ,
    ] { } make sum 4294967295 bitand ; inline

: set-vars ( -- )
    ! E = D;  D = C;  C = S^30(B);  B = A; A = TEMP;
    D get E set
    C get D set
    B get 30 32 bitroll C set
    A get B set ;

: calculate-letters ( -- )
    ! step d of RFC 3174, section 6.1
    80 [ inner-loop >r set-vars r> A set ] repeat ;

: update-hs ( -- )
    ! step e of RFC 3174, section 6.1
    A h0 update-old-new
    B h1 update-old-new
    C h2 update-old-new
    D h3 update-old-new
    E h4 update-old-new ;

: process-sha1-block ( block -- )
    make-w init-letters calculate-letters update-hs drop ;

: get-sha1 ( -- str )
    [ [ h0 h1 h2 h3 h4 ] [ get 4 >be % ] each ] "" make ;

IN: crypto
: string>sha1 ( string -- sha1 )
    [
        initialize-sha1 pad-string-sha1
        dup length num-blocks [ reset-w 2dup get-block process-sha1-block ] repeat
        drop get-sha1
    ] with-scope ;

: string>sha1str ( string -- sha1str )
    string>sha1 hex-string ;

: stream>sha1 ( stream -- sha1 ) contents string>sha1 ;

: file>sha1 ( file -- sha1 ) <file-reader> stream>sha1 ;

! unit test from the RFC
: test-sha1 ( -- )
    [ "a9993e364706816aba3e25717850c26c9cd0d89d" ] [ "abc" string>sha1str ] unit-test
    [ "84983e441c3bd26ebaae4aa1f95129e5e54670f1" ] [ "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq" string>sha1str ] unit-test
    ! [ "34aa973cd4c4daa4f61eeb2bdbad27316534016f" ] [ 1000000 CHAR: a fill string>sha1str ] unit-test ! takes a long time...
    [ "dea356a2cddd90c7a7ecedc5ebb563934f460452" ] [ "0123456701234567012345670123456701234567012345670123456701234567" [ 10 [ dup % ] times ] "" make nip string>sha1str ] unit-test ;

