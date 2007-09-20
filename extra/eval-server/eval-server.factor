! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: listener io.server strings parser byte-arrays ;
IN: eval-server

: eval-server ( -- )
    9998 local-server "eval-server" [
        >string eval>string >byte-array
    ] with-datagrams ;

MAIN: eval-server
