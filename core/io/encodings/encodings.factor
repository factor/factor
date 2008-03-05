! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel sequences sbufs vectors namespaces
growable strings io classes continuations combinators
io.styles io.streams.plain io.encodings.binary splitting
io.streams.duplex byte-arrays ;
IN: io.encodings

! The encoding descriptor protocol

GENERIC: decode-step ( buf char encoding -- )
M: object decode-step drop swap push ;

GENERIC: init-decoder ( stream encoding -- encoding )
M: tuple-class init-decoder construct-empty init-decoder ;
M: object init-decoder nip ;

GENERIC: encode-string ( string encoding -- byte-array )
M: tuple-class encode-string construct-empty encode-string ;
M: object encode-string drop >byte-array ;

! Decoding

TUPLE: decode-error ;

: decode-error ( -- * ) \ decode-error construct-empty throw ;

SYMBOL: begin

: push-decoded ( buf ch -- buf ch state )
    over push 0 begin ;

: push-replacement ( buf -- buf ch state )
    ! This is the replacement character
    HEX: fffd push-decoded ;

: space ( resizable -- room-left )
    dup underlying swap [ length ] 2apply - ;

: full? ( resizable -- ? ) space zero? ;

: end-read-loop ( buf ch state stream quot -- string/f )
    2drop 2drop >string f like ;

: decode-read-loop ( buf stream encoding -- string/f )
    pick full? [ 2drop >string ] [
        over stream-read1 [
            -rot tuck >r >r >r dupd r> decode-step r> r>
            decode-read-loop
        ] [ 2drop >string f like ] if*
    ] if ;

: decode-read ( length stream encoding -- string )
    rot <sbuf> -rot decode-read-loop ;

TUPLE: decoder code cr ;
: <decoder> ( stream encoding -- newstream )
    dup binary eq? [ drop ] [
        dupd init-decoder { set-delegate set-decoder-code }
        decoder construct
    ] if ;

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
            swap stream-read1 [ add ] when*
        ] [ nip ] if
    ] [ nip ] if ;

M: decoder stream-read
    tuck { delegate decoder-code } get-slots decode-read fix-read ;

M: decoder stream-read-partial stream-read ;

: decoder-read-until ( stream delim -- ch )
    ! Copied from { c-reader stream-read-until }!!!
    over stream-read1 dup [
        dup pick memq? [ 2nip ] [ , decoder-read-until ] if
    ] [
        2nip
    ] if ;

M: decoder stream-read-until
    ! Copied from { c-reader stream-read-until }!!!
    [ swap decoder-read-until ] "" make
    swap over empty? over not and [ 2drop f f ] when ;

: fix-read1 ( stream char -- char )
    over decoder-cr [
        over cr-
        dup CHAR: \n = [
            drop stream-read1
        ] [ nip ] if
    ] [ nip ] if ;

M: decoder stream-read1
    1 swap stream-read f like [ first ] [ f ] if* ;

M: decoder stream-readln ( stream -- str )
    "\r\n" over stream-read-until handle-readln ;

! Encoding

TUPLE: encode-error ;

: encode-error ( -- * ) \ encode-error construct-empty throw ;

TUPLE: encoder code ;
: <encoder> ( stream encoding -- newstream )
    dup binary eq? [ drop ] [
        construct-empty { set-delegate set-encoder-code }
        encoder construct
    ] if ;

M: encoder stream-write1
    >r 1string r> stream-write ;

M: encoder stream-write
    [ encoder-code encode-string ] keep delegate stream-write ;

M: encoder dispose delegate dispose ;

INSTANCE: encoder plain-writer

! Rebinding duplex streams which have not read anything yet

: reencode ( stream encoding -- newstream )
    over encoder? [ >r delegate r> ] when <encoder> ;

: redecode ( stream encoding -- newstream )
    over decoder? [ >r delegate r> ] when <decoder> ;

: <encoder-duplex> ( stream-in stream-out encoding -- duplex )
    tuck reencode >r redecode r> <duplex-stream> ;
