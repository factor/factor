! Copyright (C) 2024 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: ascii assocs base64.private byte-arrays combinators
endian io io.encodings.binary io.streams.byte-array kernel
kernel.private literals math namespaces sequences ;

IN: base45

ERROR: malformed-base45 ;

<PRIVATE

<<
CONSTANT: alphabet $[
"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ\s$%*+-./:" >byte-array ]
>>

: ch>base45 ( ch -- ch )
    alphabet nth ; inline

: base45>ch ( ch -- ch )
    $[ alphabet alphabet-inverse ] nth
    [ malformed-base45 ] unless* { fixnum } declare ; inline

: encode2 ( seq -- byte-array )
    [ be> 45 /mod swap 45 /mod swap [ ch>base45 ] tri@ ]
    [ length 2 < [ drop 2byte-array ] [ 3byte-array ] if ] bi ; inline

: (encode-base45) ( stream -- )
    2 over stream-read [ drop ] [ encode2 write (encode-base45) ] if-empty ;

PRIVATE>

: encode-base45 ( -- )
    input-stream get (encode-base45) ;

<PRIVATE

: decode3 ( seq -- )
    [ { 1 45 2025 } 0 [ [ base45>ch ] dip * + ] 2reduce ]
    [ length 3 < [ write1 ] [ 256 /mod [ write1 ] bi@ ] if ] bi ; inline

: (decode-base45) ( stream -- )
    3 "\n\r" pick read-ignoring
    [ drop ] [ decode3 (decode-base45) ] if-empty ;

PRIVATE>

: decode-base45 ( -- )
    input-stream get (decode-base45) ;

: >base45 ( seq -- base45 )
    binary [ binary [ encode-base45 ] with-byte-reader ] with-byte-writer ;

: base45> ( base45 -- seq )
    binary [ binary [ decode-base45 ] with-byte-reader ] with-byte-writer ;
