! Copyright (C) 2011 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend kernel ;
IN: ui.backend.gtk.io

HOOK: init-io-event-source io-backend ( -- )

M: object init-io-event-source ;