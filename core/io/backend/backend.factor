! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: init kernel system namespaces ;
IN: io.backend

SYMBOL: io-backend

HOOK: init-io io-backend ( -- )

HOOK: init-stdio io-backend ( -- )

HOOK: io-multiplex io-backend ( ms -- )

HOOK: normalize-directory io-backend ( str -- newstr )

M: object normalize-directory ;

HOOK: normalize-pathname io-backend ( str -- newstr )

M: object normalize-pathname ;

[ init-io embedded? [ init-stdio ] unless ]
"io.backend" add-init-hook

: set-io-backend ( backend -- )
    io-backend set-global init-io init-stdio ;
