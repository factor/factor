! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: listener io.server strings parser byte-arrays ;
IN: evald

: evald ( -- )
    9998 local-server [
        >string eval>string >byte-array
    ] with-datagrams ;

MAIN: evald
