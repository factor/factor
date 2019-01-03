! Copyright (C) 2019 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: ascii assocs kernel literals math sequences ;

IN: base32

<PRIVATE

<<
CONSTANT: ALPHABET "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
>>
CONSTANT: CHECKSUM $[ ALPHABET "*~$=U" append ]

: normalize-base32 ( seq -- seq' )
    CHAR: - swap remove >upper H{
        { CHAR: I CHAR: 1 }
        { CHAR: L CHAR: 1 }
        { CHAR: O CHAR: 0 }
    } substitute ;

: parse-base32 ( seq -- base32 )
    0 swap [ [ 32 * ] [ ALPHABET index + ] bi* ] each ;

PRIVATE>

: >base32 ( seq -- base32 )
    normalize-base32 parse-base32 ;

: base32> ( base32 -- seq )
    dup 0 < [ non-negative-integer-expected ] when
    [ dup 0 > ] [
        32 /mod ALPHABET nth
    ] "" produce-as nip [ "0" ] when-empty reverse! ;

: >base32-checksum ( seq -- base32 )
    normalize-base32 unclip-last [ parse-base32 ] dip
    CHECKSUM index over 37 mod assert= ;

: base32-checksum> ( base32 -- seq )
    [ base32> ] keep 37 mod CHECKSUM nth suffix ;
