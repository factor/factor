! Copyright (C) 2013 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.
USING: base64 base64.private combinators fry io io.binary
io.encodings.binary io.streams.byte-array kernel math
namespaces sequences ;
IN: base85

ERROR: malformed-base85 ;

<PRIVATE

: ch>base85 ( ch -- ch )
    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$%&()*+-;<=>?@^_`{|}~\";"
    nth ; inline

: base85>ch ( ch -- ch )
    {
        f f f f f f f f f f f f f f f f f f f f f f f f f f f f
        f f f f f 62 f 63 64 65 66 f 67 68 69 70 f 71 f f 0 1 2
        3 4 5 6 7 8 9 f 72 73 74 75 76 77 10 11 12 13 14 15 16
        17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35
        f f f 78 79 80 36 37 38 39 40 41 42 43 44 45 46 47 48 49
        50 51 52 53 54 55 56 57 58 59 60 61 81 82 83 84
    } nth [ malformed-base85 ] unless* ; inline

: encode4 ( seq -- )
    column output-stream get '[
        swap be> 5 [ 85 /mod ch>base85 ] replicate
        reverse! nip [ _ write1-lines ] each
    ] change ; inline

: encode-pad ( seq n -- )
    [ 4 0 pad-tail binary [ encode4 ] with-byte-writer ]
    [ 1 + ] bi* head-slice 5 CHAR: = pad-tail write-lines ; inline

: (encode-base85) ( stream -- )
    4 over stream-read dup length {
        { 0 [ 2drop ] }
        { 4 [ encode4 (encode-base85) ] }
        [ encode-pad (encode-base85) ]
    } case ;

PRIVATE>

: encode-base85 ( -- )
    input-stream get (encode-base85) ;

: encode-base85-lines ( -- )
    0 column [ encode-base85 ] with-variable ;

<PRIVATE

: decode5 ( seq -- )
    [ 0 [ [ 85 * ] [ base85>ch ] bi* + ] reduce 4 >be ]
    [ [ CHAR: = = ] count ] bi head-slice*
    output-stream get '[ _ stream-write1 ] each ; inline

: (decode-base85) ( stream -- )
    5 "\n\r" pick read-ignoring dup length {
        { 0 [ 2drop ] }
        { 5 [ decode5 (decode-base85) ] }
        [ malformed-base85 ]
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
