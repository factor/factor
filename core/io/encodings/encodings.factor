! Copyright (C) 2006, 2007 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel sequences sbufs vectors
namespaces unicode.syntax growable strings io ;
IN: io.encodings

TUPLE: encode-error ;

: encode-error ( -- * ) \ encode-error construct-empty throw ;

TUPLE: decode-error ;

: decode-error ( -- * ) \ decode-error construct-empty throw ;

SYMBOL: begin

: decoded ( buf ch -- buf ch state )
    over push 0 begin ;

: push-replacement ( buf -- buf ch state )
    UNICHAR: replacement-character decoded ;

: finish-decoding ( buf ch state -- str )
    begin eq? [ decode-error ] unless drop "" like ;

: start-decoding ( seq length -- buf ch state seq )
    <sbuf> 0 begin roll ;

: decode ( seq quot -- string )
    >r dup length start-decoding r>
    [ -rot ] swap compose each
    finish-decoding ; inline

: space ( resizable -- room-left )
    dup underlying swap [ length ] 2apply - ;

: full? ( resizable -- ? ) space zero? ;

: end-read-loop ( buf ch state stream quot -- string/f )
    2drop 2drop >string f like ;

: under ( a b c -- c a b c )
    tuck >r swapd r> ; inline

: decode-read-loop ( buf ch state stream quot -- string/f )
    >r >r pick r> r> rot full?  [ end-read-loop ] [
        over stream-read1 [
            -rot tuck >r >r >r -rot r> call r> r> decode-read-loop
        ] [ end-read-loop ] if*
    ] if ; inline

: decode-read ( length stream quot -- string )
    >r swap start-decoding r>
    decode-read-loop ; inline

GENERIC: init-decoding ( stream encoding -- decoded-stream )

: <decoding> ( stream decoding-class -- decoded-stream )
    construct-empty init-decoding ;

GENERIC: init-encoding ( stream encoding -- encoded-stream )

: <encoding> ( stream encoding-class -- encoded-stream )
    construct-empty init-encoding ;
