! Copyright (C) 2011 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend kernel ;
IN: ui.backend.gtk.io

HOOK: with-event-loop io-backend ( quot -- )

M: object with-event-loop call( -- ) ;
