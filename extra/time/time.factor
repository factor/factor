! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators system vocabs ;
IN: time

HOOK: set-system-time os ( timestamp -- )
HOOK: adjust-time-monotonic os ( timestamp -- seconds )

USE-MACOSX: time.macosx
USE-UNIX: time.unix
USE-WINDOWS: time.windows
