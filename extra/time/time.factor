! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: system ;
IN: time

HOOK: set-time os ( timestamp -- )
HOOK: adjust-time-monotonic os ( timestamp -- seconds )
