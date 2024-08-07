! Copyright (C) 2019 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: base64.private byte-arrays combinators io
io.encodings.binary io.streams.byte-array kernel kernel.private
literals math namespaces sequences ;
IN: base16

ERROR: malformed-base16 ;

! XXX: Optional handle lower-case input

<PRIVATE

<<
CONSTANT: alphabet $[ "0123456789ABCDEF" >byte-array ]
>>

: ch>base16 ( ch -- ch )
    alphabet nth ; inline

: base16>ch ( ch -- ch )
    $[ alphabet alphabet-inverse ] nth
    [ malformed-base16 ] unless* { fixnum } declare ; inline

:: (encode-base16) ( stream -- )
    stream stream-read1 [
        16 /mod [ ch>base16 write1 ] bi@
        stream (encode-base16)
    ] when* ;

PRIVATE>

: encode-base16 ( -- )
    input-stream get (encode-base16) ;

<PRIVATE

: decode2 ( seq -- n )
    first2 [ base16>ch ] bi@ [ 16 * ] [ + ] bi* ;

:: (decode-base16) ( stream -- )
    2 stream stream-read dup length {
        { 0 [ drop ] }
        { 2 [ decode2 write1 stream (decode-base16) ] }
        [ malformed-base16 ]
    } case ;

PRIVATE>

: decode-base16 ( -- )
    input-stream get (decode-base16) ;

: >base16 ( seq -- base16 )
    binary [ binary [ encode-base16 ] with-byte-reader ] with-byte-writer ;

: base16> ( base16 -- seq )
    binary [ binary [ decode-base16 ] with-byte-reader ] with-byte-writer ;
