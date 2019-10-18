! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USE: io.backend
IN: io.launcher

HOOK: run-process io-backend ( string -- )

HOOK: run-detached io-backend ( string -- )

HOOK: <process-stream> io-backend ( string -- stream )
