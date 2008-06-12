! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel sequences sbufs vectors namespaces growable
strings io classes continuations destructors combinators
io.styles io.streams.plain splitting byte-arrays
sequences.private accessors ;
IN: io.encodings

! The encoding descriptor protocol

GENERIC: decode-char ( stream encoding -- char/f )

GENERIC: encode-char ( char stream encoding -- )

GENERIC: <decoder> ( stream encoding -- newstream )

: replacement-char HEX: fffd ; inline

TUPLE: decoder stream code cr ;

ERROR: decode-error ;

GENERIC: <encoder> ( stream encoding -- newstream )

TUPLE: encoder stream code ;

ERROR: encode-error ;

! Decoding

<PRIVATE

M: object <decoder> f decoder boa ;

: >decoder< ( decoder -- stream encoding )
    [ stream>> ] [ code>> ] bi ;

: cr+ t swap set-decoder-cr ; inline

: cr- f swap set-decoder-cr ; inline

: line-ends/eof ( stream str -- str ) f like swap cr- ; inline

: line-ends\r ( stream str -- str ) swap cr+ ; inline

: line-ends\n ( stream str -- str )
    over decoder-cr over empty? and
    [ drop dup cr- stream-readln ] [ swap cr- ] if ; inline

: handle-readln ( stream str ch -- str )
    {
        { f [ line-ends/eof ] }
        { CHAR: \r [ line-ends\r ] }
        { CHAR: \n [ line-ends\n ] }
    } case ;

: fix-read ( stream string -- string )
    over decoder-cr [
        over cr-
        "\n" ?head [
            over stream-read1 [ suffix ] when*
        ] when
    ] when nip ;

: read-loop ( n stream -- string )
    SBUF" " clone [
        [
            >r nip stream-read1 dup
            [ r> push f ] [ r> 2drop t ] if
        ] 2curry find-integer drop
    ] keep "" like f like ;

M: decoder stream-read
    tuck read-loop fix-read ;

M: decoder stream-read-partial stream-read ;

: (read-until) ( buf quot -- string/f sep/f )
    ! quot: -- char stop?
    dup call
    [ >r drop "" like r> ]
    [ pick push (read-until) ] if ; inline

M: decoder stream-read-until
    SBUF" " clone -rot >decoder<
    [ decode-char [ dup rot memq? ] [ drop f t ] if* ] 3curry
    (read-until) ;

: fix-read1 ( stream char -- char )
    over decoder-cr [
        over cr-
        dup CHAR: \n = [
            drop dup stream-read1
        ] when
    ] when nip ;

M: decoder stream-read1
    dup >decoder< decode-char fix-read1 ;

M: decoder stream-readln ( stream -- str )
    "\r\n" over stream-read-until handle-readln ;

M: decoder dispose decoder-stream dispose ;

! Encoding
M: object <encoder> encoder boa ;

: >encoder< ( encoder -- stream encoding )
    [ stream>> ] [ code>> ] bi ;

M: encoder stream-write1
    >encoder< encode-char ;

M: encoder stream-write
    >encoder< [ encode-char ] 2curry each ;

M: encoder dispose encoder-stream dispose ;

M: encoder stream-flush encoder-stream stream-flush ;

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
