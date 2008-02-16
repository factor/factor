! Copyright (C) 2006, 2007 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel sequences sbufs vectors io.streams.lines io.streams.plain
namespaces unicode growable strings io classes io.streams.c
continuations ;
IN: io.encodings

TUPLE: encode-error ;

: encode-error ( -- * ) \ encode-error construct-empty throw ;

TUPLE: decode-error ;

: decode-error ( -- * ) \ decode-error construct-empty throw ;

SYMBOL: begin

: decoded ( buf ch -- buf ch state )
    over push 0 begin ;

: push-replacement ( buf -- buf ch state )
    CHAR: replacement-character decoded ;

: finish-decoding ( buf ch state -- str )
    begin eq? [ decode-error ] unless drop "" like ;

: start-decoding ( seq length -- buf ch state seq )
    <sbuf> 0 begin roll ;

GENERIC: decode-step ( buf byte ch state encoding -- buf ch state )

: decode ( seq quot -- string )
    >r dup length start-decoding r>
    [ -rot ] swap compose each
    finish-decoding ; inline

: space ( resizable -- room-left )
    dup underlying swap [ length ] 2apply - ;

: full? ( resizable -- ? ) space zero? ;

: end-read-loop ( buf ch state stream quot -- string/f )
    2drop 2drop >string f like ;

: decode-read-loop ( buf ch state stream encoding -- string/f )
    >r >r pick r> r> rot full?  [ end-read-loop ] [
        over stream-read1 [
            -rot tuck >r >r >r -rot r> decode-step r> r> decode-read-loop
        ] [ end-read-loop ] if*
    ] if ;

: decode-read ( length stream encoding -- string )
    >r swap start-decoding r>
    decode-read-loop ;

GENERIC: init-decoding ( stream encoding -- decoded-stream )

: <decoding> ( stream decoding-class -- decoded-stream )
    construct-empty init-decoding <line-reader> ;

GENERIC: init-encoding ( stream encoding -- encoded-stream )

: <encoding> ( stream encoding-class -- encoded-stream )
    construct-empty init-encoding <plain-writer> ;

GENERIC: encode-string ( string encoding -- byte-array )
M: tuple-class encode-string construct-empty encode-string ;

MIXIN: encoding-stream

M: encoding-stream init-decoding ( stream encoding-stream -- encoding-stream )
    tuck set-delegate ;

M: encoding-stream init-encoding ( stream encoding-stream -- encoding-stream )
    tuck set-delegate ;

M: encoding-stream stream-read1 1 swap stream-read ;

M: encoding-stream stream-read
    [ delegate ] keep decode-read ;

M: encoding-stream stream-read-partial stream-read ;

M: encoding-stream stream-read-until
    ! Copied from { c-reader stream-read-until }!!!
    [ swap read-until-loop ] "" make
    swap over empty? over not and [ 2drop f f ] when ;

M: encoding-stream stream-write1
    >r 1string r> stream-write ;

M: encoding-stream stream-write
    [ encode-string ] keep delegate stream-write ;

M: encoding-stream dispose delegate dispose ;
