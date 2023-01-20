! Copyright (C) 2008 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: calendar checksums checksums.md5 checksums.sha
combinators endian kernel literals math math.bitwise math.parser
random sequences ;
IN: uuid

<PRIVATE

: (timestamp) ( -- time )
    ! 0x01b21dd213814000L is the number of 100-ns intervals
    ! between the UUID epoch 1582-10-15 00:00:00 and the
    ! Unix epoch 1970-01-01 00:00:00.
    now timestamp>micros 10 * 0x01b21dd213814000 + ;

: (hardware) ( -- address )
    ! Choose a random 48-bit number with eighth bit
    ! set to 1 (as recommended in RFC 4122)
    48 random-bits 0x010000000000 bitor ;

: (clock) ( -- clockseq )
    ! Choose a random 14-bit number
    14 random-bits ;

: (version) ( n version -- n' )
    [
        0xc000 48 shift bitnot bitand
        0x8000 48 shift bitor
        0xf000 64 shift bitnot bitand
    ] dip 76 shift bitor ;

: (uuid) ( a version b variant c -- n )
    {
        [ 48 bits 80 shift ]
        [ 76 shift + ]
        [ 12 bits 64 shift + ]
        [ 62 shift + ]
        [ 62 bits + ]
    } spread ;

: uuid>string ( n -- string )
    >hex 32 CHAR: 0 pad-head
    [ CHAR: - 20 ] dip insert-nth
    [ CHAR: - 16 ] dip insert-nth
    [ CHAR: - 12 ] dip insert-nth
    [ CHAR: - 8 ] dip insert-nth ;

: string>uuid ( string -- n )
    CHAR: - swap remove hex> ;

PRIVATE>

: uuid-parse ( string -- byte-array )
    string>uuid 16 >be ;

: uuid-unparse ( byte-array -- string )
    be> uuid>string ;

: uuid1 ( -- string )
    (timestamp)
    [ 32 bits 16 shift ] [ -32 shift 16 bits + 1 ] [ -48 shift ] tri
    0b01 (clock) 48 shift (hardware) +
    (uuid) uuid>string ;

: uuid3 ( namespace name -- string )
    [ uuid-parse ] dip append
    md5 checksum-bytes 16 index-or-length head be>
    3 (version) uuid>string ;

: uuid4 ( -- string )
    128 random-bits
    4 (version) uuid>string ;

: uuid5 ( namespace name -- string )
    [ uuid-parse ] dip append
    sha1 checksum-bytes 16 index-or-length head be>
    5 (version) uuid>string ;

: uuid6 ( -- string )
    (timestamp) [ -12 shift 6 ] [ 12 bits ] bi
    0b10 (clock) 48 shift $[ 48 random-bits ] +
    (uuid) uuid>string  ;

: uuid7 ( -- string )
    now timestamp>millis 7
    12 random-bits 0b11
    62 random-bits (uuid) uuid>string ;

: uuid8 ( a b c -- string )
    [ 8 ] 2dip [ 0b01 ] dip (uuid) uuid>string ;

: uuid-urn ( string -- url )
    "url:urn:" prepend ;

CONSTANT: NAMESPACE_DNS  "6ba7b810-9dad-11d1-80b4-00c04fd430c8"
CONSTANT: NAMESPACE_URL  "6ba7b811-9dad-11d1-80b4-00c04fd430c8"
CONSTANT: NAMESPACE_OID  "6ba7b812-9dad-11d1-80b4-00c04fd430c8"
CONSTANT: NAMESPACE_X500 "6ba7b814-9dad-11d1-80b4-00c04fd430c8"
