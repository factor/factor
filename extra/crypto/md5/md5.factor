! See http://www.faqs.org/rfcs/rfc1321.html

USING: kernel io io.binary io.files io.streams.string math
math.functions math.parser namespaces splitting strings
sequences crypto.common byte-arrays locals sequences.private ;
IN: crypto.md5

<PRIVATE

SYMBOL: a
SYMBOL: b
SYMBOL: c
SYMBOL: d
SYMBOL: old-a
SYMBOL: old-b
SYMBOL: old-c
SYMBOL: old-d

: T ( N -- Y )
    sin abs 4294967296 * >bignum ; foldable

: initialize-md5 ( -- )
    0 bytes-read set
    HEX: 67452301 dup a set old-a set
    HEX: efcdab89 dup b set old-b set
    HEX: 98badcfe dup c set old-c set
    HEX: 10325476 dup d set old-d set ;

: update-md ( -- )
    old-a a update-old-new
    old-b b update-old-new
    old-c c update-old-new
    old-d d update-old-new ;

:: (ABCD) | x s i k func a b c d |
    #! a = b + ((a + F(b,c,d) + X[k] + T[i]) <<< s)
    a [
        b get c get d get func call w+
        k x nth-unsafe w+
        i T w+
        s bitroll-32
        b get w+
    ] change ; inline

: ABCD a b c d (ABCD) ; inline
: BCDA b c d a (ABCD) ; inline
: CDAB c d a b (ABCD) ; inline
: DABC d a b c (ABCD) ; inline

: F ( X Y Z -- FXYZ )
    #! F(X,Y,Z) = XY v not(X) Z
    pick bitnot bitand >r bitand r> bitor ;

: G ( X Y Z -- GXYZ )
    #! G(X,Y,Z) = XZ v Y not(Z)
    dup bitnot rot bitand >r bitand r> bitor ;

: H ( X Y Z -- HXYZ )
    #! H(X,Y,Z) = X xor Y xor Z
    bitxor bitxor ;

: I ( X Y Z -- IXYZ )
    #! I(X,Y,Z) = Y xor (X v not(Z))
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

: (process-md5-block-F)
    dup S11 1  0  [ F ] ABCD
    dup S12 2  1  [ F ] DABC
    dup S13 3  2  [ F ] CDAB
    dup S14 4  3  [ F ] BCDA
    dup S11 5  4  [ F ] ABCD
    dup S12 6  5  [ F ] DABC
    dup S13 7  6  [ F ] CDAB
    dup S14 8  7  [ F ] BCDA
    dup S11 9  8  [ F ] ABCD
    dup S12 10 9  [ F ] DABC
    dup S13 11 10 [ F ] CDAB
    dup S14 12 11 [ F ] BCDA
    dup S11 13 12 [ F ] ABCD
    dup S12 14 13 [ F ] DABC
    dup S13 15 14 [ F ] CDAB
    dup S14 16 15 [ F ] BCDA ;

: (process-md5-block-G)
    dup S21 17 1  [ G ] ABCD
    dup S22 18 6  [ G ] DABC
    dup S23 19 11 [ G ] CDAB
    dup S24 20 0  [ G ] BCDA
    dup S21 21 5  [ G ] ABCD
    dup S22 22 10 [ G ] DABC
    dup S23 23 15 [ G ] CDAB
    dup S24 24 4  [ G ] BCDA
    dup S21 25 9  [ G ] ABCD
    dup S22 26 14 [ G ] DABC
    dup S23 27 3  [ G ] CDAB
    dup S24 28 8  [ G ] BCDA
    dup S21 29 13 [ G ] ABCD
    dup S22 30 2  [ G ] DABC
    dup S23 31 7  [ G ] CDAB
    dup S24 32 12 [ G ] BCDA ;

: (process-md5-block-H)
    dup S31 33 5  [ H ] ABCD
    dup S32 34 8  [ H ] DABC
    dup S33 35 11 [ H ] CDAB
    dup S34 36 14 [ H ] BCDA
    dup S31 37 1  [ H ] ABCD
    dup S32 38 4  [ H ] DABC
    dup S33 39 7  [ H ] CDAB
    dup S34 40 10 [ H ] BCDA
    dup S31 41 13 [ H ] ABCD
    dup S32 42 0  [ H ] DABC
    dup S33 43 3  [ H ] CDAB
    dup S34 44 6  [ H ] BCDA
    dup S31 45 9  [ H ] ABCD
    dup S32 46 12 [ H ] DABC
    dup S33 47 15 [ H ] CDAB
    dup S34 48 2  [ H ] BCDA ;

: (process-md5-block-I)
    dup S41 49 0  [ I ] ABCD
    dup S42 50 7  [ I ] DABC
    dup S43 51 14 [ I ] CDAB
    dup S44 52 5  [ I ] BCDA
    dup S41 53 12 [ I ] ABCD
    dup S42 54 3  [ I ] DABC
    dup S43 55 10 [ I ] CDAB
    dup S44 56 1  [ I ] BCDA
    dup S41 57 8  [ I ] ABCD
    dup S42 58 15 [ I ] DABC
    dup S43 59 6  [ I ] CDAB
    dup S44 60 13 [ I ] BCDA
    dup S41 61 4  [ I ] ABCD
    dup S42 62 11 [ I ] DABC
    dup S43 63 2  [ I ] CDAB
    dup S44 64 9  [ I ] BCDA ;

: (process-md5-block) ( block -- )
    4 group [ le> ] map

    (process-md5-block-F)
    (process-md5-block-G)
    (process-md5-block-H)
    (process-md5-block-I)

    drop

    update-md ;

: process-md5-block ( str -- )
    dup length [ bytes-read [ + ] change ] keep 64 = [
        (process-md5-block)
    ] [
        f bytes-read get pad-last-block
        [ (process-md5-block) ] each
    ] if ;
    
: (stream>md5) ( -- )
    64 read [ process-md5-block ] keep
    length 64 = [ (stream>md5) ] when ;

: get-md5 ( -- str )
    [ a b c d ] [ get 4 >le ] map concat >byte-array ;

PRIVATE>

: stream>md5 ( stream -- byte-array )
    [ initialize-md5 (stream>md5) get-md5 ] with-stream ;

: string>md5 ( string -- byte-array ) <string-reader> stream>md5 ;
: string>md5str ( string -- md5-string ) string>md5 hex-string ;
: file>md5 ( path -- byte-array ) <file-reader> stream>md5 ;
: file>md5str ( path -- md5-string ) file>md5 hex-string ;
