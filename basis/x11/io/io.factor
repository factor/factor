! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend calendar threads kernel ;
IN: x11.io

HOOK: init-x-io io-backend ( -- )

M: object init-x-io ;

HOOK: wait-for-display io-backend ( -- )

M: object wait-for-display 10 milliseconds sleep ;

HOOK: awaken-event-loop io-backend ( -- )

M: object awaken-event-loop ;