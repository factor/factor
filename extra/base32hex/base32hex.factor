! Copyright (C) 2022 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: base64.private byte-arrays combinators endian io
io.encodings.binary io.streams.byte-array kernel kernel.private
literals math namespaces sequences ;
IN: base32hex

ERROR: malformed-base32hex ;

! XXX: Optional map 0 as O
! XXX: Optional map 1 as L or I
! XXX: Optional handle lower-case input

<PRIVATE

<<
CONSTANT: alphabet $[ "0123456789ABCDEFGHIJKLMNOPQRSTUV" >byte-array ]
>>

: ch>base32hex ( ch -- ch )
    alphabet nth ; inline

: base32hex>ch ( ch -- ch )
    $[ alphabet alphabet-inverse 0 CHAR: = pick set-nth ] nth
    [ malformed-base32hex ] unless* { fixnum } declare ; inline

: encode5 ( seq -- byte-array )
    be> { -35 -30 -25 -20 -15 -10 -5 0 } '[
        shift 0x1f bitand ch>base32hex
    ] with B{ } map-as ; inline

: encode-pad ( seq n -- byte-array )
    [ 5 0 pad-tail encode5 ] [ B{ 0 2 4 5 7 } nth ] bi* head-slice
    8 CHAR: = pad-tail ; inline

: (encode-base32hex) ( stream column -- )
    5 pick stream-read dup length {
        { 0 [ 3drop ] }
        { 5 [ encode5 write-lines (encode-base32hex) ] }
        [ encode-pad write-lines (encode-base32hex) ]
    } case ;

PRIVATE>

: encode-base32hex ( -- )
    input-stream get f (encode-base32hex) ;

: encode-base32hex-lines ( -- )
    input-stream get 0 (encode-base32hex) ;

<PRIVATE

: decode8 ( seq -- )
    [ 0 [ base32hex>ch swap 5 shift bitor ] reduce 5 >be ]
    [ [ CHAR: = = ] count ] bi
    [ write ] [ B{ 0 4 0 3 2 0 1 } nth head-slice write ] if-zero ; inline

: (decode-base32hex) ( stream -- )
    8 "\n\r" pick read-ignoring dup length {
        { 0 [ 2drop ] }
        { 8 [ decode8 (decode-base32hex) ] }
        [ drop 8 CHAR: = pad-tail decode8 (decode-base32hex) ]
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
