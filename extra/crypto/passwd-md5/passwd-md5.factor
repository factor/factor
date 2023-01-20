! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: checksums checksums.md5 combinators grouping kernel math
math.bits math.functions sequences splitting ;
IN: crypto.passwd-md5

<PRIVATE

: lookup-table ( n -- nth )
    "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" nth ; inline

: to64 ( v n -- string )
    [ [ -6 shift ] [ 6 2^ 1 - bitand lookup-table ] bi ]
    replicate nip ; inline

PRIVATE>

:: passwd-md5 ( magic salt password -- bytes )
    password magic salt 3append
    salt password 1surround md5 checksum-bytes
    password length
    [ 16 / ceiling swap <repetition> concat ] keep
    head-slice append
    password [ length make-bits ] [ first ] bi
    '[ CHAR: \0 _ ? ] "" map-as append
    md5 checksum-bytes :> final!

    1000 <iota> [
        "" swap
        {
            [ 0 bit? password final ? append ]
            [ 3 mod 0 > [ salt append ] when ]
            [ 7 mod 0 > [ password append ] when ]
            [ 0 bit? final password ? append ]
        } cleave md5 checksum-bytes final!
    ] each

    magic salt "$" 3append
    { 12 0 6 13 1 7 14 2 8 15 3 9 5 4 10 } final nths 3 group
    [ first3 [ 16 shift ] [ 8 shift ] bi* + + 4 to64 ] map concat
    11 final nth 2 to64 3append ;

: parse-shadow-password ( string -- magic salt password )
    "$" split harvest first3 [ "$" 1surround ] 2dip ;

: authenticate-password ( shadow password -- ? )
    '[ parse-shadow-password drop _ passwd-md5 ] keep = ;
