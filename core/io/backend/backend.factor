! Copyright (C) 2007, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs init io io.encodings io.encodings.utf8 kernel
namespaces system ;
IN: io.backend

SYMBOL: io-backend

SINGLETON: c-io-backend

io-backend [ c-io-backend ] initialize

HOOK: init-io io-backend ( -- )

HOOK: init-stdio io-backend ( -- )

: set-stdio ( input output error -- )
    [ utf8 <decoder> input-stream set-global ]
    [ utf8 <encoder> output-stream set-global ]
    [ utf8 <encoder> error-stream set-global ] tri* ;

HOOK: io-multiplex io-backend ( nanos -- )

HOOK: normalize-path io-backend ( path -- path' )

: set-io-backend ( io-backend -- )
    io-backend set-global init-io init-stdio
    "io.files" startup-hooks get at call( -- ) ;

STARTUP-HOOK: [ init-io embedded? [ init-stdio ] unless ]
