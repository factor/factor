IN: crypto
USING: kernel io strings sequences namespaces math prettyprint
unparser test parser lists ;

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

: (F) ( vars func -- vars result )
    >r dup second get over third get pick fourth get r> call ; inline

! # bits to shift, input to float-sin, x, func
: (ABCD) ( s i x vars func -- )
    (F) swap >r w+ swap float-sin w+ r> dup first >r swap r> update
    dup first get rot 32 bitroll
    over second get w+ swap first set ; inline

: ABCD [ a b c d ] swap (ABCD) ; inline
: BCDA [ b c d a ] swap (ABCD) ; inline
: CDAB [ c d a b ] swap (ABCD) ; inline
: DABC [ d a b c ] swap (ABCD) ; inline

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

: S11 7 ;
: S12 12 ;
: S13 17 ;
: S14 22 ;
: S21 5 ;
: S22 9 ;
: S23 14 ;
: S24 20 ;
: S31 4 ;
: S32 11 ;
: S33 16 ;
: S34 23 ;
: S41 6 ;
: S42 10 ;
: S43 15 ;
: S44 21 ;

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
    S44 64 pick 9 nth-int  [ I ] BCDA
    update-md
    drop
    ;

: get-md5 ( -- str )
    [
        [ a b c d ] [ get 4 >le % ] each
    ] make-string hex-string ;

: string>md5 ( string -- md5 )
    [
        initialize-md5 pad-string-md5
        dup length num-blocks [ 2dup get-block process-md5-block ] repeat
        drop get-md5
    ] with-scope ;

: stream>md5 ( stream -- md5 )
    [
        contents string>md5
    ] with-scope ;

: file>md5 ( file -- md5 )
    [
        <file-reader> stream>md5
    ] with-scope ;

: test-md5 ( -- )
    [ "d41d8cd98f00b204e9800998ecf8427e" ] [ "" string>md5 ] unit-test
    [ "0cc175b9c0f1b6a831c399e269772661" ] [ "a" string>md5 ] unit-test
    [ "900150983cd24fb0d6963f7d28e17f72" ] [ "abc" string>md5 ] unit-test
    [ "f96b697d7cb7938d525a2f31aaf161d0" ] [ "message digest" string>md5 ] unit-test
    [ "c3fcd3d76192e4007dfb496cca67e13b" ] [ "abcdefghijklmnopqrstuvwxyz" string>md5 ] unit-test
    [ "d174ab98d277d9f5a5611c2c9f419d9f" ] [ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" string>md5 ] unit-test
    [ "57edf4a22be3c955ac49da2e2107b67a" ] [ "12345678901234567890123456789012345678901234567890123456789012345678901234567890" string>md5 ] unit-test
    ;

