! Copyright (C) 2019 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: base64.private byte-arrays combinators endian io
io.encodings.binary io.streams.byte-array kernel kernel.private
literals math namespaces sequences ;
IN: base32

ERROR: malformed-base32 ;

! XXX: Optional map 0 as O
! XXX: Optional map 1 as L or I
! XXX: Optional handle lower-case input

<PRIVATE

<<
CONSTANT: alphabet $[ "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567" >byte-array ]
>>

: ch>base32 ( ch -- ch )
    alphabet nth ; inline

: base32>ch ( ch -- ch )
    $[ alphabet alphabet-inverse 0 CHAR: = pick set-nth ] nth
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
