! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend ;
IN: io.monitor

HOOK: <monitor> io-backend ( path -- monitor )

HOOK: next-change io-backend ( monitor -- path )

: with-monitor ( directory quot -- )
    >r <monitor> r> over [ close-monitor ] curry [ ] cleanup ;
