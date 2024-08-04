! Copyright (C) 2013 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: base64.private byte-arrays combinators endian io
io.encodings.binary io.streams.byte-array kernel kernel.private
literals math namespaces sequences splitting tr ;
IN: base85

ERROR: malformed-base85 ;

<PRIVATE

<<
CONSTANT: base85-alphabet $[
    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$%&()*+-;<=>?@^_`{|}~"
    >byte-array
]
>>

: ch>base85 ( ch -- ch )
    base85-alphabet nth ; inline

: base85>ch ( ch -- ch )
    $[ base85-alphabet alphabet-inverse ] nth
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

<PRIVATE

<<
CONSTANT: z85-alphabet $[
    "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-:+=^!/*?&<>()[]{}@%$#"
    >byte-array
]
>>

TR: base85>z85 $ base85-alphabet $ z85-alphabet ;

TR: z85>base85 $[ z85-alphabet ";_`|~" append ] $[ base85-alphabet B{ 0 0 0 0 0 } append ] ;

PRIVATE>

: >z85 ( seq -- z85 )
    >base85 base85>z85 ;

: z85> ( z85 -- seq )
    z85>base85 base85> ;

ERROR: malformed-ascii85 ;

<PRIVATE

<<
CONSTANT: ascii85-alphabet $[
    "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstu"
    >byte-array
]
>>

: ch>ascii85 ( ch -- ch )
    ascii85-alphabet nth ; inline

: ascii85>ch ( ch -- ch )
    $[ ascii85-alphabet alphabet-inverse ] nth
    [ malformed-ascii85 ] unless* { fixnum } declare ; inline

: encode4' ( seq -- seq' )
    be> [ B{ CHAR: z } ] [
        5 [ 85 /mod ch>ascii85 ] B{ } replicate-as reverse! nip
    ] if-zero ; inline

: (encode-ascii85) ( stream -- )
    4 over stream-read dup length {
        { 0 [ 2drop ] }
        { 4 [ encode4' write (encode-ascii85) ] }
        [
            drop
            [ 4 0 pad-tail encode4' ]
            [ length 4 swap - head-slice* write ] bi
            (encode-ascii85)
        ]
    } case ;

PRIVATE>

: encode-ascii85 ( -- )
    input-stream get (encode-ascii85) ;

<PRIVATE

: decode5' ( seq -- seq' )
    0 [ [ 85 * ] [ 33 - ] bi* + ] reduce 4 >be ; inline

: (decode-ascii85) ( stream -- )
   " \t\n\r\v" over read1-ignoring {
        { CHAR: z [ B{ 0 0 0 0 } write (decode-ascii85) ] }
        { f [ drop ] }
        [
            [ 4 " \t\n\r\v" pick read-ignoring ]
            [ prefix ] bi* dup length  {
                { 0 [ 2drop ] }
                { 5 [ decode5' write (decode-ascii85) ] }
                [
                    drop
                    [ 5 CHAR: u pad-tail decode5' ]
                    [ length 5 swap - head-slice* write ] bi
                    (decode-ascii85)
                ]
            } case
        ]
    } case ;

PRIVATE>

: decode-ascii85 ( -- )
    input-stream get (decode-ascii85) ;

: >ascii85 ( seq -- ascii85 )
    binary [ binary [ encode-ascii85 ] with-byte-reader ] with-byte-writer ;

: ascii85> ( ascii85 -- seq )
    binary [ binary [ decode-ascii85 ] with-byte-reader ] with-byte-writer ;

: >adobe85 ( seq -- adobe85 )
    >ascii85 "<~" "~>" surround ;

: adobe85> ( adobe85 -- seq )
    "<~" ?head drop "~>" ?tail t assert= ascii85> ;
