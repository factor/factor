! Copyright (C) 2008 Doug Coleman, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs byte-arrays combinators growable io
io.encodings.binary io.streams.byte-array kernel kernel.private
literals math math.bitwise namespaces sbufs sequences
sequences.private ;
IN: base64

ERROR: malformed-base64 ;

<PRIVATE

<<
CONSTANT: alphabet $[
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    >byte-array
]

: alphabet-inverse ( alphabet -- seq )
    dup supremum 1 + f <array> [
        '[ swap _ set-nth ] each-index
    ] keep ;
>>

: ch>base64 ( ch -- ch )
    alphabet nth ; inline

: base64>ch ( ch -- ch )
    $[ alphabet alphabet-inverse 0 CHAR: = pick set-nth ] nth
    [ malformed-base64 ] unless* { fixnum } declare ; inline

: encode3 ( x y z -- a b c d )
    { fixnum fixnum fixnum } declare {
        [ [ -2 shift ch>base64 ] [ 2 bits 4 shift ] bi ]
        [ [ -4 shift bitor ch>base64 ] [ 4 bits 2 shift ] bi ]
        [ [ -6 shift bitor ch>base64 ] [ 6 bits ch>base64 ] bi ]
    } spread ; inline

:: (stream-write-lines) ( column data stream -- column' )
    column data over 71 > [
        [
            stream stream-write1 1 + dup 76 = [
                drop 0
                B{ CHAR: \r CHAR: \n } stream stream-write
            ] when
        ] each
    ] [
        stream stream-write 4 +
    ] if ; inline

: stream-write-lines ( column data stream -- column' )
    pick [ (stream-write-lines) ] [ stream-write ] if ; inline

: write-lines ( column data -- column' )
    output-stream get stream-write-lines ; inline

:: (encode-base64) ( input output column -- )
    4 <byte-array> :> data
    column [ input stream-read1 dup ] [
        input stream-read1
        input stream-read1
        [ [ 0 or ] bi@ encode3 ] 2keep [ 0 1 ? ] bi@ + {
            { 0 [ ] }
            { 1 [ drop CHAR: = ] }
            { 2 [ 2drop CHAR: = CHAR: = ] }
        } case data (4sequence) output stream-write-lines
    ] while 2drop ; inline

PRIVATE>

: encode-base64 ( -- )
    input-stream get output-stream get f (encode-base64) ;

: encode-base64-lines ( -- )
    input-stream get output-stream get 0 (encode-base64) ;

<PRIVATE

: read1-ignoring ( ignoring stream -- ch )
    dup stream-read1 pick dupd member-eq?
    [ drop read1-ignoring ] [ 2nip ] if ; inline recursive

: read-ignoring ( n ignoring stream -- accum )
    pick <sbuf> [
        '[ _ _ read1-ignoring [ ] _ push-when ] times
    ] keep ;

: decode4 ( a b c d -- x y z )
    { fixnum fixnum fixnum fixnum } declare {
        [ base64>ch 2 shift ]
        [ base64>ch [ -4 shift bitor ] [ 4 bits 4 shift ] bi ]
        [ base64>ch [ -2 shift bitor ] [ 2 bits 6 shift ] bi ]
        [ base64>ch bitor ]
    } spread ; inline

:: (decode-base64) ( input output -- )
    3 <byte-array> :> data
    [ B{ CHAR: \n CHAR: \r } input read1-ignoring ] [
        B{ CHAR: \n CHAR: \r } input read1-ignoring CHAR: = or
        B{ CHAR: \n CHAR: \r } input read1-ignoring CHAR: = or
        B{ CHAR: \n CHAR: \r } input read1-ignoring CHAR: = or
        [ decode4 data (3sequence) ] 3keep
        [ CHAR: = eq? 1 0 ? ] tri@ + +
        [ head-slice* ] unless-zero
        output stream-write
    ] while* ;

PRIVATE>

: decode-base64 ( -- )
    input-stream get output-stream get (decode-base64) ;

<PRIVATE

: ensure-encode-length ( base64 -- base64 )
    dup length 3 /mod zero? [ 1 + ] unless 4 *
    output-stream get expand ;

: ensure-decode-length ( seq -- seq )
    dup length 4 /mod zero? [ 1 + ] unless 3 *
    output-stream get expand ;

PRIVATE>

: >base64 ( seq -- base64 )
    binary [
        ensure-encode-length
        binary [ encode-base64 ] with-byte-reader
    ] with-byte-writer ;

: base64> ( base64 -- seq )
    binary [
        ensure-decode-length
        binary [ decode-base64 ] with-byte-reader
    ] with-byte-writer ;

: >base64-lines ( seq -- base64 )
    binary [
        ensure-encode-length
        binary [ encode-base64-lines ] with-byte-reader
    ] with-byte-writer ;

: >urlsafe-base64 ( seq -- base64 )
    >base64 H{
        { CHAR: + CHAR: - }
        { CHAR: / CHAR: _ }
    } substitute ;

: >urlsafe-base64-jwt ( seq -- base64 )
    >urlsafe-base64 [ CHAR: = = ] trim-tail ;

: urlsafe-base64> ( base64 -- seq )
    H{
        { CHAR: - CHAR: + }
        { CHAR: _ CHAR: / }
    } substitute base64> ;

: >urlsafe-base64-lines ( seq -- base64 )
    >base64-lines H{
        { CHAR: + CHAR: - }
        { CHAR: / CHAR: _ }
    } substitute ;
