! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel sequences sbufs vectors namespaces growable
strings io classes continuations destructors combinators
io.streams.plain splitting byte-arrays
sequences.private accessors ;
IN: io.encodings

! The encoding descriptor protocol

GENERIC: decode-char ( stream encoding -- char/f )

GENERIC: encode-char ( char stream encoding -- )

GENERIC: <decoder> ( stream encoding -- newstream )

CONSTANT: replacement-char HEX: fffd

TUPLE: decoder stream code cr ;

ERROR: decode-error ;

GENERIC: <encoder> ( stream encoding -- newstream )

TUPLE: encoder stream code ;

ERROR: encode-error ;

! Decoding

M: object <decoder> f decoder boa ;

<PRIVATE

: cr+ ( stream -- ) t >>cr drop ; inline

: cr- ( stream -- ) f >>cr drop ; inline

: >decoder< ( decoder -- stream encoding )
    [ stream>> ] [ code>> ] bi ; inline

: fix-read1 ( stream char -- char )
    over cr>> [
        over cr-
        dup CHAR: \n = [
            drop dup stream-read1
        ] when
    ] when nip ; inline

M: decoder stream-element-type
    drop +character+ ;

M: decoder stream-read1
    dup >decoder< decode-char fix-read1 ;

: fix-read ( stream string -- string )
    over cr>> [
        over cr-
        "\n" ?head [
            over stream-read1 [ suffix ] when*
        ] when
    ] when nip ; inline

: (read) ( n quot -- n string )
    over 0 <string> [
        [
            over [ swapd set-nth-unsafe f ] [ 3drop t ] if
        ] curry compose find-integer
    ] keep ; inline

: finish-read ( n string -- string/f )
    {
        { [ over 0 = ] [ 2drop f ] }
        { [ over not ] [ nip ] }
        [ swap head ]
    } cond ; inline

M: decoder stream-read
    [ nip ] [ >decoder< [ decode-char ] 2curry (read) finish-read ] 2bi
    fix-read ;

M: decoder stream-read-partial stream-read ;

: line-ends/eof ( stream str -- str ) f like swap cr- ; inline

: line-ends\r ( stream str -- str ) swap cr+ ; inline

: line-ends\n ( stream str -- str )
    over cr>> over empty? and
    [ drop dup cr- stream-readln ] [ swap cr- ] if ; inline

: handle-readln ( stream str ch -- str )
    {
        { f [ line-ends/eof ] }
        { CHAR: \r [ line-ends\r ] }
        { CHAR: \n [ line-ends\n ] }
    } case ; inline

: ((read-until)) ( buf quot: ( -- char stop? ) -- string/f sep/f )
    dup call
    [ [ drop "" like ] dip ]
    [ pick push ((read-until)) ] if ; inline recursive

: (read-until) ( quot -- string/f sep/f )
    100 <sbuf> swap ((read-until)) ; inline

: decoder-read-until ( seps stream encoding -- string/f sep/f )
    [ decode-char dup [ dup rot member? ] [ 2drop f t ] if ] 3curry
    (read-until) ;

M: decoder stream-read-until >decoder< decoder-read-until ;

: decoder-readln ( stream encoding -- string/f sep/f )
    [ decode-char dup [ dup "\r\n" member? ] [ drop f t ] if ] 2curry
    (read-until) ;

M: decoder stream-readln dup >decoder< decoder-readln handle-readln ;

M: decoder dispose stream>> dispose ;

! Encoding
M: object <encoder> encoder boa ;

: >encoder< ( encoder -- stream encoding )
    [ stream>> ] [ code>> ] bi ; inline

M: encoder stream-element-type
    drop +character+ ;

M: encoder stream-write1
    >encoder< encode-char ;

GENERIC# encoder-write 2 ( string stream encoding -- )

M: string encoder-write
    [ encode-char ] 2curry each ;

M: encoder stream-write
    >encoder< encoder-write ;

M: encoder dispose stream>> dispose ;

M: encoder stream-flush stream>> stream-flush ;

INSTANCE: encoder plain-writer
PRIVATE>

GENERIC# re-encode 1 ( stream encoding -- newstream )

M: object re-encode <encoder> ;

M: encoder re-encode [ stream>> ] dip re-encode ;

: encode-output ( encoding -- )
    output-stream [ swap re-encode ] change ;

: with-encoded-output ( encoding quot -- )
    [ [ output-stream get ] dip re-encode ] dip
    with-output-stream* ; inline

GENERIC# re-decode 1 ( stream encoding -- newstream )

M: object re-decode <decoder> ;

M: decoder re-decode [ stream>> ] dip re-decode ;

: decode-input ( encoding -- )
    input-stream [ swap re-decode ] change ;

: with-decoded-input ( encoding quot -- )
    [ [ input-stream get ] dip re-decode ] dip
    with-input-stream* ; inline
