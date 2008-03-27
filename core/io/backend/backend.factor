! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: init kernel system namespaces io io.encodings
io.encodings.utf8 init assocs ;
IN: io.backend

SYMBOL: io-backend

HOOK: init-io io-backend ( -- )

HOOK: (init-stdio) io-backend ( -- stdin stdout stderr )

: init-stdio ( -- )
    (init-stdio) utf8 <encoder> stderr set-global
    utf8 <encoder-duplex> stdio set-global ;

HOOK: io-multiplex io-backend ( ms -- )

HOOK: normalize-directory io-backend ( str -- newstr )

HOOK: normalize-pathname io-backend ( str -- newstr )

M: object normalize-directory normalize-pathname ;

: set-io-backend ( io-backend -- )
    io-backend set-global init-io init-stdio
    "io.files" init-hooks get at call ;

[ init-io embedded? [ init-stdio ] unless ]
"io.backend" add-init-hook
