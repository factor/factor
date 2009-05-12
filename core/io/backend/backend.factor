! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: init kernel system namespaces io io.encodings
io.encodings.utf8 init assocs splitting alien ;
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
