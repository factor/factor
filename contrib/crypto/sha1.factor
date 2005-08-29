IN: crypto
USING: kernel io strings sequences namespaces math prettyprint
unparser test parser lists vectors ;

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
SYMBOL: temp
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

: update-hs ( -- )
    A h0 update-old-new
    B h1 update-old-new
    C h2 update-old-new
    D h3 update-old-new
    E h4 update-old-new ;

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
: sha1-f ( B C D t -- f_tbcd )
    dup 20 < [
        drop >r over bitnot r> bitand >r bitand r> bitor
    ] [ dup 40 < [
            drop bitxor bitxor
        ] [ dup 60 < [
                drop 2dup bitand >r pick bitand >r bitand r> r> bitor bitor
            ] [
                drop bitxor bitxor
            ] ifte
        ] ifte
    ] ifte ;

: process-sha1-block ( block -- )
    ! compute w, steps a-b of RFC 3174, section 6.1
    80 [ dup 16 < [
            [ nth-int-be w get push ] 2keep
        ] [
            dup sha1-W w get push
        ] ifte 
    ] repeat

    ! step c of RFC 3174, section 6.1
    h0 get A set
    h1 get B set
    h2 get C set
    h3 get D set
    h4 get E set

    ! step d of RFC 3174, section 6.1
    80 [
        ! TEMP = S^5(A) + f(t;B,C,D) + E + W(t) + K(t);
        dup B get C get D get rot4 sha1-f
        over get-wth
        pick K get nth
        A get 5 32 bitroll
        E get
        + + + +
        4294967296 mod
        temp set

        ! E = D;  D = C;  C = S^30(B);  B = A; A = TEMP;
        D get E set
        C get D set
        B get 30 32 bitroll C set
        A get B set
        temp get A set
    ] repeat

    ! step e of RFC 3174, section 6.1
    update-hs
    drop ;

: get-sha1 ( -- str )
    [
        [ h0 h1 h2 h3 h4 ] [ get 4 >be % ] each
    ] "" make hex-string ;

: string>sha1 ( string -- sha1 )
    [
        initialize-sha1 pad-string-sha1
        dup length num-blocks [ reset-w 2dup get-block process-sha1-block ] repeat
        drop get-sha1
    ] with-scope ;

: stream>sha1 ( stream -- sha1 )
    [
        contents string>sha1
    ] with-scope ;

: file>sha1 ( file -- sha1 )
    [
        <file-reader> stream>sha1
    ] with-scope ;

! unit test from the RFC
: test-sha1 ( -- )
    [ "a9993e364706816aba3e25717850c26c9cd0d89d" ] [ "abc" string>sha1 ] unit-test
    [ "84983e441c3bd26ebaae4aa1f95129e5e54670f1" ] [ "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq" string>sha1 ] unit-test
    ! [ "34aa973cd4c4daa4f61eeb2bdbad27316534016f" ] [ 1000000 CHAR: a fill string>sha1 ] unit-test ! takes a long time...
    [ "dea356a2cddd90c7a7ecedc5ebb563934f460452" ] [ "0123456701234567012345670123456701234567012345670123456701234567" [ 10 [ dup % ] times ] "" make nip string>sha1 ] unit-test ;

