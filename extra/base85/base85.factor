! Copyright (C) 2013 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: base64.private byte-arrays combinators endian io
io.encodings.binary io.streams.byte-array kernel kernel.private
literals math namespaces sequences ;
IN: base85

ERROR: malformed-base85 ;

<PRIVATE

<<
CONSTANT: alphabet $[
    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$%&()*+-;<=>?@^_`{|}~"
    >byte-array
]
>>

: ch>base85 ( ch -- ch )
    alphabet nth ; inline

: base85>ch ( ch -- ch )
    $[ alphabet alphabet-inverse ] nth
    [ malformed-base85 ] unless* { fixnum } declare ; inline

: encode4 ( seq -- seq' )
    be> 5 [ 85 /mod ch>base85 ] B{ } replicate-as reverse! nip ; inline

: (encode-base85) ( stream column -- )
    4 pick stream-read dup length {
        { 0 [ 3drop ] }
        { 4 [ encode4 write-lines (encode-base85) ] }
        [
            drop
            [ 4 0 pad-tail encode4 ]
            [ length 4 swap - head-slice* write-lines ] bi
            (encode-base85)
        ]
    } case ;

PRIVATE>

: encode-base85 ( -- )
    input-stream get f (encode-base85) ;

: encode-base85-lines ( -- )
    input-stream get 0 (encode-base85) ;

<PRIVATE

: decode5 ( seq -- seq' )
    0 [ [ 85 * ] [ base85>ch ] bi* + ] reduce 4 >be ; inline

: (decode-base85) ( stream -- )
    5 "\n\r" pick read-ignoring dup length {
        { 0 [ 2drop ] }
        { 5 [ decode5 write (decode-base85) ] }
        [
            drop
            [ 5 CHAR: ~ pad-tail decode5 ]
            [ length 5 swap - head-slice* write ] bi
            (decode-base85)
        ]
    } case ;

PRIVATE>

: decode-base85 ( -- )
    input-stream get (decode-base85) ;

: >base85 ( seq -- base85 )
    binary [ binary [ encode-base85 ] with-byte-reader ] with-byte-writer ;

: base85> ( base85 -- seq )
    binary [ binary [ decode-base85 ] with-byte-reader ] with-byte-writer ;

: >base85-lines ( seq -- base85 )
    binary [ binary [ encode-base85-lines ] with-byte-reader ] with-byte-writer ;
