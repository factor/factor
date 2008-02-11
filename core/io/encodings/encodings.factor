! Copyright (C) 2006, 2007 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel sequences sbufs vectors
namespaces unicode.syntax ;
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

: decode ( ch state seq quot -- buf ch state )
    [ -rot ] swap compose each ; inline

: start-decoding ( seq -- buf ch state seq )
    [ length <sbuf> 0 begin ] keep ;

GENERIC: init-decoding ( stream encoding -- decoded-stream )

: <decoding> ( stream decoding-class -- decoded-stream )
    construct-empty init-decoding ;

GENERIC: init-encoding ( stream encoding -- encoded-stream )

: <encoding> ( stream encoding-class -- encoded-stream )
    construct-empty init-encoding ;
