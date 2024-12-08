! Copyright (C) 2019 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: ascii assocs base64.private byte-arrays combinators
endian io io.encodings.binary io.streams.byte-array kernel
kernel.private literals math namespaces sequences ;

IN: base32

ERROR: malformed-base32 ;

! XXX: Optional map 0 as O
! XXX: Optional map 1 as L or I
! XXX: Optional handle lower-case input

<PRIVATE

<<
CONSTANT: base32-alphabet $[ "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567" >byte-array ]
>>

: ch>base32 ( ch -- ch )
    base32-alphabet nth ; inline

: base32>ch ( ch -- ch )
    $[ base32-alphabet alphabet-inverse 0 CHAR: = pick set-nth ] nth
    [ malformed-base32 ] unless* { fixnum } declare ; inline

: encode5 ( seq -- byte-array )
    be> { -35 -30 -25 -20 -15 -10 -5 0 } '[
        shift 0x1f bitand ch>base32
    ] with B{ } map-as ; inline

: encode-pad ( seq n -- byte-array )
    [ 5 0 pad-tail encode5 ] [ B{ 0 2 4 5 7 } nth ] bi* head-slice
    8 CHAR: = pad-tail ; inline

: (encode-base32) ( stream column -- )
    5 pick stream-read dup length {
        { 0 [ 3drop ] }
        { 5 [ encode5 write-lines (encode-base32) ] }
        [ encode-pad write-lines (encode-base32) ]
    } case ;

PRIVATE>

: encode-base32 ( -- )
    input-stream get f (encode-base32) ;

: encode-base32-lines ( -- )
    input-stream get 0 (encode-base32) ;

<PRIVATE

: decode8 ( seq -- )
    [ 0 [ base32>ch swap 5 shift bitor ] reduce 5 >be ]
    [ [ CHAR: = = ] count ] bi
    [ write ] [ B{ 0 4 0 3 2 0 1 } nth head-slice write ] if-zero ; inline

: (decode-base32) ( stream -- )
    8 "\n\r" pick read-ignoring dup length {
        { 0 [ 2drop ] }
        { 8 [ decode8 (decode-base32) ] }
        [ drop 8 CHAR: = pad-tail decode8 (decode-base32) ]
    } case ;

PRIVATE>

: decode-base32 ( -- )
    input-stream get (decode-base32) ;

: >base32 ( seq -- base32 )
    binary [ binary [ encode-base32 ] with-byte-reader ] with-byte-writer ;

: base32> ( base32 -- seq )
    binary [ binary [ decode-base32 ] with-byte-reader ] with-byte-writer ;

: >base32-lines ( seq -- base32 )
    binary [ binary [ encode-base32-lines ] with-byte-reader ] with-byte-writer ;

ERROR: malformed-base32hex ;

! XXX: Optional map 0 as O
! XXX: Optional map 1 as L or I
! XXX: Optional handle lower-case input

<PRIVATE

<<
CONSTANT: base32hex-alphabet $[ "0123456789ABCDEFGHIJKLMNOPQRSTUV" >byte-array ]
>>

: ch>base32hex ( ch -- ch )
    base32hex-alphabet nth ; inline

: base32hex>ch ( ch -- ch )
    $[ base32hex-alphabet alphabet-inverse 0 CHAR: = pick set-nth ] nth
    [ malformed-base32hex ] unless* { fixnum } declare ; inline

: encode5hex ( seq -- byte-array )
    be> { -35 -30 -25 -20 -15 -10 -5 0 } '[
        shift 0x1f bitand ch>base32hex
    ] with B{ } map-as ; inline

: encode-padhex ( seq n -- byte-array )
    [ 5 0 pad-tail encode5hex ] [ B{ 0 2 4 5 7 } nth ] bi* head-slice
    8 CHAR: = pad-tail ; inline

: (encode-base32hex) ( stream column -- )
    5 pick stream-read dup length {
        { 0 [ 3drop ] }
        { 5 [ encode5hex write-lines (encode-base32hex) ] }
        [ encode-padhex write-lines (encode-base32hex) ]
    } case ;

PRIVATE>

: encode-base32hex ( -- )
    input-stream get f (encode-base32hex) ;

: encode-base32hex-lines ( -- )
    input-stream get 0 (encode-base32hex) ;

<PRIVATE

: decode8hex ( seq -- )
    [ 0 [ base32hex>ch swap 5 shift bitor ] reduce 5 >be ]
    [ [ CHAR: = = ] count ] bi
    [ write ] [ B{ 0 4 0 3 2 0 1 } nth head-slice write ] if-zero ; inline

: (decode-base32hex) ( stream -- )
    8 "\n\r" pick read-ignoring dup length {
        { 0 [ 2drop ] }
        { 8 [ decode8hex (decode-base32hex) ] }
        [ drop 8 CHAR: = pad-tail decode8hex (decode-base32hex) ]
    } case ;

PRIVATE>

: decode-base32hex ( -- )
    input-stream get (decode-base32hex) ;

: >base32hex ( seq -- base32 )
    binary [ binary [ encode-base32hex ] with-byte-reader ] with-byte-writer ;

: base32hex> ( base32 -- seq )
    binary [ binary [ decode-base32hex ] with-byte-reader ] with-byte-writer ;

: >base32hex-lines ( seq -- base32 )
    binary [ binary [ encode-base32hex-lines ] with-byte-reader ] with-byte-writer ;

<PRIVATE

<<
CONSTANT: base32-crockford-alphabet $[ "0123456789ABCDEFGHJKMNPQRSTVWXYZ" >byte-array ]
>>

CONSTANT: base32-crockford-inverse $[ 256 [ base32-crockford-alphabet index 0xff or ] B{ } map-integers-as ]

CONSTANT: base32-crockford-checksum $[ base32-crockford-alphabet "*~$=U" append ]

: normalize-base32-crockford ( base32 -- base32' )
    CHAR: - swap remove >upper H{
        { CHAR: I CHAR: 1 }
        { CHAR: L CHAR: 1 }
        { CHAR: O CHAR: 0 }
    } substitute ;

: parse-base32-crockford ( base32 -- n )
    0 swap [ [ 32 * ] [ base32-crockford-inverse nth + ] bi* ] each ;

PRIVATE>

: base32-crockford> ( base32 -- n )
    normalize-base32-crockford parse-base32-crockford ;

: >base32-crockford ( n -- base32 )
    assert-non-negative
    [ dup 0 > ] [ 32 /mod base32-crockford-alphabet nth ] "" produce-as nip
    [ "0" ] when-empty reverse! ;

: base32-crockford-checksum> ( base32 -- n )
    normalize-base32-crockford unclip-last [ parse-base32-crockford ] dip
    base32-crockford-checksum index over 37 mod assert= ;

: >base32-crockford-checksum ( n -- base32 )
    [ >base32-crockford ] keep 37 mod base32-crockford-checksum nth suffix ;

ERROR: malformed-zbase32 ;

<PRIVATE

<<
CONSTANT: zbase32-alphabet $[ "ybndrfg8ejkmcpqxot1uwisza345h769" >byte-array ]
>>

: ch>zbase32 ( ch -- ch )
    zbase32-alphabet nth ; inline

: zbase32>ch ( ch -- ch )
    $[ zbase32-alphabet alphabet-inverse 0 CHAR: = pick set-nth ] nth
    [ malformed-zbase32 ] unless* { fixnum } declare ; inline

: zencode5 ( seq -- byte-array )
    be> { -35 -30 -25 -20 -15 -10 -5 0 } '[
        shift 0x1f bitand ch>zbase32
    ] with B{ } map-as ; inline

: zencode-pad ( seq n -- byte-array )
    [ 5 0 pad-tail zencode5 ] [ B{ 0 2 4 5 7 } nth ] bi* head-slice
    8 CHAR: = pad-tail ; inline

: (encode-zbase32) ( stream column -- )
    5 pick stream-read dup length {
        { 0 [ 3drop ] }
        { 5 [ zencode5 write-lines (encode-zbase32) ] }
        [ zencode-pad write-lines (encode-zbase32) ]
    } case ;

PRIVATE>

: encode-zbase32 ( -- )
    input-stream get f (encode-zbase32) ;

: encode-zbase32-lines ( -- )
    input-stream get 0 (encode-zbase32) ;

<PRIVATE

: zdecode8 ( seq -- )
    [ 0 [ zbase32>ch swap 5 shift bitor ] reduce 5 >be ]
    [ [ CHAR: = = ] count ] bi
    [ write ] [ B{ 0 4 0 3 2 0 1 } nth head-slice write ] if-zero ; inline

: (decode-zbase32) ( stream -- )
    8 "\n\r" pick read-ignoring dup length {
        { 0 [ 2drop ] }
        { 8 [ zdecode8 (decode-zbase32) ] }
        [ drop 8 CHAR: = pad-tail zdecode8 (decode-zbase32) ]
    } case ;

PRIVATE>

: decode-zbase32 ( -- )
    input-stream get (decode-zbase32) ;

: >zbase32 ( seq -- zbase32 )
    binary [ binary [ encode-zbase32 ] with-byte-reader ] with-byte-writer ;

: zbase32> ( zbase32 -- seq )
    binary [ binary [ decode-zbase32 ] with-byte-reader ] with-byte-writer ;

: >zbase32-lines ( seq -- zbase32 )
    binary [ binary [ encode-zbase32-lines ] with-byte-reader ] with-byte-writer ;
