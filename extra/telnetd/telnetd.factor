! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: listener io.server ;
IN: telnetd

: telnetd ( -- )
    9999 local-server [ listener ] with-server ;

MAIN: telnetd
