! Copyright (C) 2008, 2010 Daniel Ehrenberg, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors byte-arrays combinators destructors io
io.private io.streams.plain kernel kernel.private math
namespaces sbufs sequences sequences.private strings
strings.private ;

IN: io.encodings

! The encoding descriptor protocol

GENERIC: guess-encoded-length ( string-length encoding -- byte-length )
GENERIC: guess-decoded-length ( byte-length encoding -- string-length )

M: object guess-decoded-length drop ; inline
M: object guess-encoded-length drop ; inline

GENERIC: decode-char ( stream encoding -- char/f )

GENERIC: decode-until ( seps stream encoding -- string/f sep/f )

<PRIVATE

! If the stop? branch is taken convert the sbuf to a string
! If sep is present, returns ``string sep'' (string can be "")
! If sep is f, returns ``string f'' or ``f f''
: decode-until-loop ( buf quot: ( -- char stop? ) -- string/f sep/f )
    dup call
    [ nip [ "" like ] dip [ f like f ] unless* ]
    [ pick push decode-until-loop ] if ; inline recursive

PRIVATE>

: (decode-until) ( seps stream encoding -- string/f sep/f )
    [ decode-char dup ] 2curry swap [ dupd member? ] curry
    [ [ drop f t ] if ] curry compose
    [ 100 <sbuf> ] dip decode-until-loop ; inline

M: object decode-until (decode-until) ;

CONSTANT: replacement-char 0xfffd

<PRIVATE

: string>byte-array-fast ( string -- byte-array )
    { string } declare ! aux>> must be f
    [ length ] keep over (byte-array) [
        [
            [ [ string-nth-fast ] keepd ]
            [ set-nth-unsafe ] bi*
        ] 2curry each-integer
    ] keep ; inline

: byte-array>string-fast ( byte-array -- string )
    { byte-array } declare
    [ length ] keep over 0 <string> [
        [
            [ [ nth-unsafe ] keepd ]
            [
                pick 127 <=
                [ set-string-nth-fast ]
                [ [ drop replacement-char ] 2dip set-string-nth-slow ]
                if
            ] bi*
        ] 2curry each-integer
    ] keep dup reset-string-hashcode ;

PRIVATE>

GENERIC: encode-char ( char stream encoding -- )

GENERIC: encode-string ( string stream encoding -- )

M: object encode-string [ encode-char ] 2curry each ; inline

GENERIC: <decoder> ( stream encoding -- newstream )

TUPLE: decoder { stream read-only } { code read-only } { cr boolean } ;

INSTANCE: decoder input-stream

ERROR: decode-error ;

GENERIC: <encoder> ( stream encoding -- newstream )

TUPLE: encoder { stream read-only } { code read-only } ;

INSTANCE: encoder output-stream

ERROR: encode-error ;

! Decoding

M: object <decoder> f decoder boa ; inline

<PRIVATE

: cr+ ( stream -- ) t >>cr drop ; inline

: cr- ( stream -- ) f >>cr drop ; inline

: >decoder< ( decoder -- stream encoding )
    [ stream>> ] [ code>> ] bi ; inline

M: decoder stream-element-type
    drop +character+ ; inline

: decode1 ( decoder -- ch )
    >decoder< decode-char ; inline

: fix-cr ( decoder c -- c' )
    over cr>> [
        over cr- dup CHAR: \n eq? [ drop decode1 ] [ nip ] if
    ] [ nip ] if ; inline

M: decoder stream-read1
    dup decode1 fix-cr ; inline

: decode-first ( n buf decoder -- buf stream encoding n c )
    [ rot [ >decoder< ] dip 2over decode-char ]
    [ swap fix-cr ] bi ; inline

: store-decode ( buf stream encoding n c i -- buf stream encoding n )
    [ rot [ set-nth-unsafe ] keep ] 2curry 3dip ; inline

: decode-next ( stream encoding n i -- stream encoding n i c )
    [ 2dup decode-char ] 2dip rot ; inline

: decode-rest ( buf stream encoding n i -- count )
    2dup = [ 4nip ] [
        decode-next [
            swap [ store-decode ] [ 1 + ] bi decode-rest
        ] [ 4nip ] if*
    ] if ; inline recursive

M: decoder stream-read-unsafe
    pick 0 = [ 3drop 0 ] [
        decode-first [
            0 store-decode
            1 decode-rest
        ] [ 4drop 0 ] if*
    ] if ; inline

M: decoder stream-contents* stream-contents-by-element ; inline

: line-ends/eof ( stream str -- str/f ) f like swap cr- ; inline

: line-ends\r ( stream str -- str ) swap cr+ ; inline

: line-ends\n ( stream str -- str )
    over cr>> [
        over cr- [ stream-readln ] [ nip ] if-empty
    ] [ nip ] if ; inline

: handle-readln ( stream str ch -- str/f )
    {
        { f [ line-ends/eof ] }
        { CHAR: \r [ line-ends\r ] }
        { CHAR: \n [ line-ends\n ] }
    } case ; inline

M: decoder stream-read-until
    dup cr>> [
        dup cr- 2dup
        >decoder< decode-until
        over [
            dup CHAR: \n = [
                2drop stream-read-until
            ] [
                2nipd
            ] if
        ] [
            first-unsafe CHAR: \n = [ [ rest ] dip ] when
            2nipd
        ] if-empty
    ] [
        >decoder< decode-until
    ] if ;

M: decoder stream-readln
    "\r\n" over >decoder< decode-until handle-readln ;

M: decoder dispose stream>> dispose ;

! Encoding
M: object <encoder> encoder boa ; inline

: >encoder< ( encoder -- stream encoding )
    [ stream>> ] [ code>> ] bi ; inline

M: encoder stream-element-type
    drop +character+ ; inline

M: encoder stream-write1
    >encoder< encode-char ; inline

M: encoder stream-write
    >encoder< encode-string ; inline

M: encoder dispose stream>> dispose ; inline

M: encoder stream-flush stream>> stream-flush ; inline

INSTANCE: encoder plain-writer

PRIVATE>

GENERIC#: re-encode 1 ( stream encoding -- newstream )

M: object re-encode <encoder> ;

M: encoder re-encode [ stream>> ] dip re-encode ;

: encode-output ( encoding -- )
    output-stream [ swap re-encode ] change ;

: with-encoded-output ( encoding quot -- )
    [ [ output-stream get ] dip re-encode ] dip
    with-output-stream* ; inline

GENERIC#: re-decode 1 ( stream encoding -- newstream )

M: object re-decode <decoder> ;

M: decoder re-decode [ stream>> ] dip re-decode ;

: decode-input ( encoding -- )
    input-stream [ swap re-decode ] change ;

: with-decoded-input ( encoding quot -- )
    [ [ input-stream get ] dip re-decode ] dip
    with-input-stream* ; inline
