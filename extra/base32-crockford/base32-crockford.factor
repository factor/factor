! Copyright (C) 2019 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: ascii assocs byte-arrays kernel literals math sequences ;

IN: base32-crockford

<PRIVATE

<<
CONSTANT: ALPHABET $[ "0123456789ABCDEFGHJKMNPQRSTVWXYZ" >byte-array ]
>>

CONSTANT: INVERSE $[ 256 [ ALPHABET index 0xff or ] B{ } map-integers-as ]

CONSTANT: CHECKSUM $[ ALPHABET "*~$=U" append ]

: normalize-base32 ( base32 -- base32' )
    CHAR: - swap remove >upper H{
        { CHAR: I CHAR: 1 }
        { CHAR: L CHAR: 1 }
        { CHAR: O CHAR: 0 }
    } substitute ;

: parse-base32 ( base32 -- n )
    0 swap [ [ 32 * ] [ INVERSE nth + ] bi* ] each ;

PRIVATE>

: base32-crockford> ( base32 -- n )
    normalize-base32 parse-base32 ;

: >base32-crockford ( n -- base32 )
    assert-non-negative
    [ dup 0 > ] [ 32 /mod ALPHABET nth ] "" produce-as nip
    [ "0" ] when-empty reverse! ;

: base32-crockford-checksum> ( base32 -- n )
    normalize-base32 unclip-last [ parse-base32 ] dip
    CHECKSUM index over 37 mod assert= ;

: >base32-crockford-checksum ( n -- base32 )
    [ >base32-crockford ] keep 37 mod CHECKSUM nth suffix ;
