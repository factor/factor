USING: kernel io strings sequences namespaces math parser
vectors hashtables math-contrib crypto ;
IN: crypto-internals

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

: get-wth ( n -- wth ) w get nth ; inline
: shift-wth ( n -- x ) get-wth 1 bitroll-32 ; inline

: initialize-sha1 ( -- )
    0 bytes-read set
    HEX: 67452301 dup h0 set A set
    HEX: efcdab89 dup h1 set B set
    HEX: 98badcfe dup h2 set C set
    HEX: 10325476 dup h3 set D set
    HEX: c3d2e1f0 dup h4 set E set
    [
        20 [ HEX: 5a827999 , ] times
        20 [ HEX: 6ed9eba1 , ] times
        20 [ HEX: 8f1bbcdc , ] times
        20 [ HEX: ca62c1d6 , ] times
    ] { } make K set ;

! W(t) = S^1(W(t-3) XOR W(t-8) XOR W(t-14) XOR W(t-16))
: sha1-W ( t -- W_t )
     dup 3 - get-wth
     over 8 - get-wth bitxor
     over 14 - get-wth bitxor
     swap 16 - get-wth bitxor 1 bitroll-32 ;

! f(t;B,C,D) = (B AND C) OR ((NOT B) AND D)         ( 0 <= t <= 19)
! f(t;B,C,D) = B XOR C XOR D                        (20 <= t <= 39)
! f(t;B,C,D) = (B AND C) OR (B AND D) OR (C AND D)  (40 <= t <= 59)
! f(t;B,C,D) = B XOR C XOR D                        (60 <= t <= 79)
: sha1-f ( B C D t -- f_tbcd )
    #! Maybe use dispatch
    20 /i
    {   
        { [ dup 0 = ] [ drop >r over bitnot r> bitand >r bitand r> bitor ] }
        { [ dup 1 = ] [ drop bitxor bitxor ] }
        { [ dup 2 = ] [ drop 2dup bitand >r pick bitand >r bitand r> r> bitor bitor ] }
        { [ dup 3 = ] [ drop bitxor bitxor ] }
    } cond ;

: make-w ( str -- )
    #! compute w, steps a-b of RFC 3174, section 6.1
    16 [ nth-int-be w get push ] each-with
    16 80 dup <slice> [ sha1-W w get push ] each ;

: init-letters ( -- )
    ! step c of RFC 3174, section 6.1
    h0 get A set
    h1 get B set
    h2 get C set
    h3 get D set
    h4 get E set ;

: inner-loop ( n -- temp )
    ! TEMP = S^5(A) + f(t;B,C,D) + E + W(t) + K(t);
    [
        [ B get C get D get ] keep sha1-f ,
        dup get-wth ,
        K get nth ,
        A get 5 bitroll-32 ,
        E get ,
    ] { } make sum 4294967295 bitand ; inline

: set-vars ( temp -- )
    ! E = D;  D = C;  C = S^30(B);  B = A; A = TEMP;
    D get E set
    C get D set
    B get 30 bitroll-32 C set
    A get B set
    A set ;

: calculate-letters ( -- )
    ! step d of RFC 3174, section 6.1
    80 [ inner-loop set-vars ] each ;

: update-hs ( -- )
    ! step e of RFC 3174, section 6.1
    A h0 update-old-new
    B h1 update-old-new
    C h2 update-old-new
    D h3 update-old-new
    E h4 update-old-new ;

: process-sha1-block ( str -- )
    80 <vector> w set make-w init-letters calculate-letters update-hs ;

: get-sha1 ( -- str )
    [ [ h0 h1 h2 h3 h4 ] [ get 4 >be % ] each ] "" make ;

: (stream>sha1) ( -- )
    64 read dup length dup bytes-read [ + ] change 64 = [
        process-sha1-block (stream>sha1)
    ] [
        t bytes-read get pad-last-block [ process-sha1-block ] each
    ] if ;

IN: crypto

: stream>sha1 ( stream -- sha1 )
    [ [ initialize-sha1 (stream>sha1) get-sha1 ] with-stream ] with-scope ;

: string>sha1 ( string -- sha1 ) <string-reader> stream>sha1 ;
: string>sha1str ( string -- str ) string>sha1 hex-string ;
: file>sha1 ( file -- sha1 ) <file-reader> stream>sha1 ;

