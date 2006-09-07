USING: kernel io strings sequences namespaces math parser crypto ;
IN: crypto-internals

SYMBOL: a
SYMBOL: b
SYMBOL: c
SYMBOL: d
SYMBOL: old-a
SYMBOL: old-b
SYMBOL: old-c
SYMBOL: old-d

: initialize-md5 ( -- )
    HEX: 67452301 dup a set old-a set
    HEX: efcdab89 dup b set old-b set
    HEX: 98badcfe dup c set old-c set
    HEX: 10325476 dup d set old-d set ;

: update-md ( -- )
    old-a a update-old-new
    old-b b update-old-new
    old-c c update-old-new
    old-d d update-old-new ;

! Let [abcd k s i] denote the operation
! a = b + ((a + F(b,c,d) + X[k] + T[i]) <<< s)

: 1to4 dup second get over third get pick fourth get ;

: (F) ( vars func -- vars result ) >r 1to4 r> call ; inline

: (ABCD) ( s i x vars result -- )
    #! bits to shift, input to float-sin, x, func
    swap >r w+ swap float-sin w+ r> dup first >r swap r> update
    dup first get rot 32 bitroll over second get w+ swap first set ;

: ABCD { a b c d } swap (F) (ABCD) ; inline
: BCDA { b c d a } swap (F) (ABCD) ; inline
: CDAB { c d a b } swap (F) (ABCD) ; inline
: DABC { d a b c } swap (F) (ABCD) ; inline

! F(X,Y,Z) = XY v not(X) Z
: F ( X Y Z -- FXYZ )
    pick bitnot bitand >r bitand r> bitor ;

! G(X,Y,Z) = XZ v Y not(Z)
: G ( X Y Z -- GXYZ )
    dup bitnot rot bitand >r bitand r> bitor ;
    
! H(X,Y,Z) = X xor Y xor Z
: H ( X Y Z -- HXYZ )
    bitxor bitxor ;
    
! I(X,Y,Z) = Y xor (X v not(Z))
: I ( X Y Z -- IXYZ )
    rot swap bitnot bitor bitxor ;
: S11 7  ; inline
: S12 12 ; inline
: S13 17 ; inline
: S14 22 ; inline
: S21 5  ; inline
: S22 9  ; inline
: S23 14 ; inline
: S24 20 ; inline
: S31 4 ;  inline
: S32 11 ; inline
: S33 16 ; inline
: S34 23 ; inline
: S41 6  ; inline
: S42 10 ; inline
: S43 15 ; inline
: S44 21 ; inline

: process-md5-block ( block -- )
    S11 1 pick 0 nth-int   [ F ] ABCD
    S12 2 pick 1 nth-int   [ F ] DABC
    S13 3 pick 2 nth-int   [ F ] CDAB
    S14 4 pick 3 nth-int   [ F ] BCDA
    S11 5 pick 4 nth-int   [ F ] ABCD
    S12 6 pick 5 nth-int   [ F ] DABC
    S13 7 pick 6 nth-int   [ F ] CDAB
    S14 8 pick 7 nth-int   [ F ] BCDA
    S11 9 pick 8 nth-int   [ F ] ABCD
    S12 10 pick 9 nth-int  [ F ] DABC
    S13 11 pick 10 nth-int [ F ] CDAB
    S14 12 pick 11 nth-int [ F ] BCDA
    S11 13 pick 12 nth-int [ F ] ABCD
    S12 14 pick 13 nth-int [ F ] DABC
    S13 15 pick 14 nth-int [ F ] CDAB
    S14 16 pick 15 nth-int [ F ] BCDA

    S21 17 pick 1 nth-int  [ G ] ABCD
    S22 18 pick 6 nth-int  [ G ] DABC
    S23 19 pick 11 nth-int [ G ] CDAB
    S24 20 pick 0 nth-int  [ G ] BCDA
    S21 21 pick 5 nth-int  [ G ] ABCD
    S22 22 pick 10 nth-int [ G ] DABC
    S23 23 pick 15 nth-int [ G ] CDAB
    S24 24 pick 4 nth-int  [ G ] BCDA
    S21 25 pick 9 nth-int  [ G ] ABCD
    S22 26 pick 14 nth-int [ G ] DABC
    S23 27 pick 3 nth-int  [ G ] CDAB
    S24 28 pick 8 nth-int  [ G ] BCDA
    S21 29 pick 13 nth-int [ G ] ABCD
    S22 30 pick 2 nth-int  [ G ] DABC
    S23 31 pick 7 nth-int  [ G ] CDAB
    S24 32 pick 12 nth-int [ G ] BCDA

    S31 33 pick 5 nth-int  [ H ] ABCD
    S32 34 pick 8 nth-int  [ H ] DABC
    S33 35 pick 11 nth-int [ H ] CDAB
    S34 36 pick 14 nth-int [ H ] BCDA
    S31 37 pick 1 nth-int  [ H ] ABCD
    S32 38 pick 4 nth-int  [ H ] DABC
    S33 39 pick 7 nth-int  [ H ] CDAB
    S34 40 pick 10 nth-int [ H ] BCDA
    S31 41 pick 13 nth-int [ H ] ABCD
    S32 42 pick 0 nth-int  [ H ] DABC
    S33 43 pick 3 nth-int  [ H ] CDAB
    S34 44 pick 6 nth-int  [ H ] BCDA
    S31 45 pick 9 nth-int  [ H ] ABCD
    S32 46 pick 12 nth-int [ H ] DABC
    S33 47 pick 15 nth-int [ H ] CDAB
    S34 48 pick 2 nth-int  [ H ] BCDA

    S41 49 pick 0 nth-int  [ I ] ABCD
    S42 50 pick 7 nth-int  [ I ] DABC
    S43 51 pick 14 nth-int [ I ] CDAB
    S44 52 pick 5 nth-int  [ I ] BCDA
    S41 53 pick 12 nth-int [ I ] ABCD
    S42 54 pick 3 nth-int  [ I ] DABC
    S43 55 pick 10 nth-int [ I ] CDAB
    S44 56 pick 1 nth-int  [ I ] BCDA
    S41 57 pick 8 nth-int  [ I ] ABCD
    S42 58 pick 15 nth-int [ I ] DABC
    S43 59 pick 6 nth-int  [ I ] CDAB
    S44 60 pick 13 nth-int [ I ] BCDA
    S41 61 pick 4 nth-int  [ I ] ABCD
    S42 62 pick 11 nth-int [ I ] DABC
    S43 63 pick 2 nth-int  [ I ] CDAB
    S44 64 rot 9 nth-int  [ I ] BCDA
    update-md ;

: get-md5 ( -- str )
    [ [ a b c d ] [ get 4 >le % ] each ] "" make ;

IN: crypto

: string>md5 ( string -- md5 )
    [
        initialize-md5 f preprocess-plaintext
        64 group [ process-md5-block ] each get-md5
    ] with-scope ;

: string>md5str ( string -- str ) string>md5 hex-string ;
: stream>md5 ( stream -- md5 ) contents string>md5 ;
: file>md5 ( file -- md5 ) <file-reader> stream>md5 ;

