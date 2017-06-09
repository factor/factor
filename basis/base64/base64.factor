! Copyright (C) 2008 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators fry io io.binary io.encodings.binary
io.streams.byte-array kernel literals math namespaces sbufs
sequences ;
IN: base64

ERROR: malformed-base64 ;

<PRIVATE

<<
CONSTANT: alphabet
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

: alphabet-inverse ( alphabet -- seq )
    dup supremum 1 + f <array> [
        '[ swap _ set-nth ] each-index
    ] keep ;
>>

: ch>base64 ( ch -- ch )
    alphabet nth ; inline

: base64>ch ( ch -- ch )
    $[ alphabet alphabet-inverse 0 CHAR: = pick set-nth ] nth
    [ malformed-base64 ] unless* ; inline

: (write-lines) ( column byte-array -- column' )
    output-stream get dup '[
        _ stream-write1 1 + dup 76 = [
            drop B{ CHAR: \r CHAR: \n } _ stream-write 0
        ] when
    ] each ; inline

: write-lines ( column byte-array -- column' )
    over [ (write-lines) ] [ write ] if ; inline

: encode3 ( seq -- byte-array )
    be> { -18 -12 -6 0 } '[
        shift 0x3f bitand ch>base64
    ] with B{ } map-as ; inline

: encode-pad ( seq n -- byte-array )
    [ 3 0 pad-tail encode3 ] [ 1 + ] bi* head-slice
    4 CHAR: = pad-tail ; inline

: (encode-base64) ( stream column -- )
    3 pick stream-read dup length {
        { 0 [ 3drop ] }
        { 3 [ encode3 write-lines (encode-base64) ] }
        [ encode-pad write-lines (encode-base64) ]
    } case ;

PRIVATE>

: encode-base64 ( -- )
    input-stream get f (encode-base64) ;

: encode-base64-lines ( -- )
    input-stream get 0 (encode-base64) ;

<PRIVATE

: read1-ignoring ( ignoring stream -- ch )
    dup stream-read1 pick dupd member?
    [ drop read1-ignoring ] [ 2nip ] if ; inline recursive

: push-ignoring ( accum ch -- accum )
    dup { f 0 } member-eq? [ drop ] [ suffix! ] if ; inline

: read-into-ignoring ( accum n ignoring stream -- accum )
    '[ _ _ read1-ignoring push-ignoring ] times ; inline

: read-ignoring ( n ignoring stream -- accum )
    [ [ <sbuf> ] keep ] 2dip read-into-ignoring ; inline

: decode4 ( seq -- )
    [ 0 [ base64>ch swap 6 shift bitor ] reduce 3 >be ]
    [ [ CHAR: = = ] count ] bi
    [ write ] [ head-slice* write ] if-zero ; inline

: (decode-base64) ( stream -- )
    4 "\n\r" pick read-ignoring dup length {
        { 0 [ 2drop ] }
        { 4 [ decode4 (decode-base64) ] }
        [ drop 4 CHAR: = pad-tail decode4 (decode-base64) ]
    } case ;

PRIVATE>

: decode-base64 ( -- )
    input-stream get (decode-base64) ;

: >base64 ( seq -- base64 )
    binary [ binary [ encode-base64 ] with-byte-reader ] with-byte-writer ;

: base64> ( base64 -- seq )
    binary [ binary [ decode-base64 ] with-byte-reader ] with-byte-writer ;

: >base64-lines ( seq -- base64 )
    binary [ binary [ encode-base64-lines ] with-byte-reader ] with-byte-writer ;
