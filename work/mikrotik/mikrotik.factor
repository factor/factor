! Copyright (C) 2012 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: ;
IN: mikrotik

SYMBOL: fdSock

: connect ( -- )
    "192.168.0.1" 8728 apiConnect
    ;


