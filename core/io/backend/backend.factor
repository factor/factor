! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: init kernel system namespaces io io.encodings
io.encodings.utf8 init assocs splitting alien io.streams.null ;
IN: io.backend

SYMBOL: io-backend

SINGLETON: c-io-backend

io-backend [ c-io-backend ] initialize

HOOK: init-io io-backend ( -- )

HOOK: (init-stdio) io-backend ( -- stdin stdout stderr ? )

: set-stdio ( input-handle output-handle error-handle -- )
    [ input-stream set-global ]
    [ output-stream set-global ]
    [ error-stream set-global ] tri* ;

: init-stdio ( -- )
    (init-stdio) [
        [ utf8 <decoder> ]
        [ utf8 <encoder> ]
        [ utf8 <encoder> ] tri*
    ] [
        3drop
        null-reader null-writer null-writer
    ] if set-stdio ;

HOOK: io-multiplex io-backend ( us -- )

HOOK: normalize-directory io-backend ( str -- newstr )

HOOK: normalize-path io-backend ( str -- newstr )

M: object normalize-directory normalize-path ;

: set-io-backend ( io-backend -- )
    io-backend set-global init-io init-stdio
    "io.files" init-hooks get at call( -- ) ;

! Note that we have 'alien' in our using list so that the alien
! init hook runs before this one.
[ init-io embedded? [ init-stdio ] unless ]
"io.backend" add-init-hook
