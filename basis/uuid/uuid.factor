! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: byte-arrays checksums checksums.md5 checksums.sha
kernel math math.parser math.ranges random unicode.case 
sequences strings system io.binary ;

IN: uuid 

<PRIVATE

: (timestamp) ( -- time_high time_mid time_low ) 
    ! 0x01b21dd213814000L is the number of 100-ns intervals
    ! between the UUID epoch 1582-10-15 00:00:00 and the 
    ! Unix epoch 1970-01-01 00:00:00.
    system-micros 10 * HEX: 01b21dd213814000 +
    [ -48 shift HEX: 0fff bitand ] 
    [ -32 shift HEX: ffff bitand ]
    [ HEX: ffffffff bitand ]
    tri ;

: (hardware) ( -- address ) 
    ! Choose a random 48-bit number with eighth bit 
    ! set to 1 (as recommended in RFC 4122)
    48 random-bits HEX: 010000000000 bitor ;

: (clock) ( -- clockseq ) 
    ! Choose a random 14-bit number
    14 random-bits ;

: <uuid> ( address clockseq time_high time_mid time_low -- n )
    96 shift 
    [ 80 shift ] dip bitor 
    [ 64 shift ] dip bitor
    [ 48 shift ] dip bitor
    bitor ;

: (version) ( n version -- n' )
    [
        HEX: c000 48 shift bitnot bitand 
        HEX: 8000 48 shift bitor 
        HEX: f000 64 shift bitnot bitand
    ] dip 76 shift bitor ;

: uuid>string ( n -- string )
    >hex 32 CHAR: 0 pad-head 
    [ CHAR: - 20 ] dip insert-nth
    [ CHAR: - 16 ] dip insert-nth 
    [ CHAR: - 12 ] dip insert-nth 
    [ CHAR: - 8 ] dip insert-nth ;
 
: string>uuid ( string -- n )
    [ CHAR: - = not ] filter 16 base> ;

PRIVATE>

: uuid-parse ( string -- byte-array ) 
    string>uuid 16 >be ;

: uuid-unparse ( byte-array -- string ) 
    be> uuid>string ;

: uuid1 ( -- string )
    (hardware) (clock) (timestamp) <uuid> 
    1 (version) uuid>string ;

: uuid3 ( namespace name -- string )
    [ uuid-parse ] dip append 
    md5 checksum-bytes 16 short head be> 
    3 (version) uuid>string ;

: uuid4 ( -- string )
    128 random-bits 
    4 (version) uuid>string ;

: uuid5 ( namespace name -- string )
    [ uuid-parse ] dip append 
    sha1 checksum-bytes 16 short head be> 
    5 (version) uuid>string ;

CONSTANT: NAMESPACE_DNS  "6ba7b810-9dad-11d1-80b4-00c04fd430c8"
CONSTANT: NAMESPACE_URL  "6ba7b811-9dad-11d1-80b4-00c04fd430c8"
CONSTANT: NAMESPACE_OID  "6ba7b812-9dad-11d1-80b4-00c04fd430c8"
CONSTANT: NAMESPACE_X500 "6ba7b814-9dad-11d1-80b4-00c04fd430c8"


