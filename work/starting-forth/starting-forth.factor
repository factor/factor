! Copyright (C) 2012 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: ;

IN: starting-forth

: SPACES ( n -- )
    [ CHAR: space ] replicate-as write ;
