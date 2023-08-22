! Copyright (C) 2018, 2019 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: ascii binary-search calendar endian kernel make math
math.bitwise math.order namespaces random sequences splitting
summary system tr ;

IN: ulid

ERROR: ulid-overflow ;
M: ulid-overflow summary drop "Too many ULIDs generated per msec" ;

<PRIVATE

CONSTANT: encoding "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
CONSTANT: base 32
CONSTANT: 80-bits 0xFFFFFFFFFFFFFFFFFFFF

SYMBOL: last-time-string
SYMBOL: last-random-bits

: encode-bits ( n chars -- string )
    [ base /mod encoding nth ] "" replicate-as nip reverse! ;

: encode-random-bits ( n -- string )
    16 encode-bits ;

: encode-time ( timestamp -- string )
    timestamp>millis 10 encode-bits ;

: same-millisecond? ( -- ? )
    nano-count 1,000,000 /i dup \ same-millisecond? get =
    [ drop t ] [ \ same-millisecond? set f ] if ;

: pack-bits ( seq -- seq' )
    5 swap [ first ] [ rest ] bi [
        [ ! can-take-bits overflow-byte elt
            pick 5 >= [
                swap 5 shift bitor swap 5 - [ , 0 8 ] when-zero swap
            ] [
                3dup rot [ shift ] [ 5 - shift ] bi-curry bi* bitor ,
                nip 5 rot - [ bits 8 ] keep - swap
            ] if
        ] each 2drop
    ] B{ } make ;

TR: (normalize-ulid) "ILO" "110" ; inline

: (ulid) ( same-millisecond? -- ulid )
    [
        last-time-string get last-random-bits get 1 +
        dup 80-bits > [ ulid-overflow ] when
    ] [
        now encode-time dup last-time-string set
        80 random-bits
    ] if dup last-random-bits set encode-random-bits append ;

PRIVATE>

: ulid ( -- ulid )
    same-millisecond? (ulid) ;

ERROR: ulid>bytes-bad-length n ;
M: ulid>bytes-bad-length summary drop "Invalid ULID length" ;

ERROR: ulid>bytes-bad-character ch ;
M: ulid>bytes-bad-character summary drop "Invalid character in ULID" ;

ERROR: ulid>bytes-overflow ;
M: ulid>bytes-overflow summary drop "Overflow error in ULID" ;

: ulid>bytes ( ulid -- byte-array )
    dup length dup 26 = [ drop ] [ ulid>bytes-bad-length ] if
    [
        dup [ >=< ] curry encoding swap search pick =
        [ nip ] [ drop ulid>bytes-bad-character ] if
    ] B{ } map-as dup first 7 > [ ulid>bytes-overflow ] when pack-bits ;

: normalize-ulid ( str -- str' )
    >upper (normalize-ulid) ;

ERROR: bytes>ulid-bad-length n ;
M: bytes>ulid-bad-length summary drop "Invalid ULID byte-array length" ;

: bytes>ulid ( byte-array -- ulid )
    dup length dup 16 = [ drop ] [ bytes>ulid-bad-length ] if
    be> 26 encode-bits ;
