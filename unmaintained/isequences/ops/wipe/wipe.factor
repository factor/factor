! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.

IN: isequences.ops.wipe
USING: generic kernel math sequences isequences.interface isequences.base ;


TUPLE: iwiped sequence ;

: <i-wiped> ( s -- iwiped ) 
    dup i-length zero? [ drop 0 ] [ <iwiped> ] if ; inline

M: iwiped i-length iwiped-sequence i-length ;
M: iwiped i-at >r iwiped-sequence r> i-at right-side <i-right-sided> ;
M: iwiped ileft iwiped-sequence ileft <iwiped> ;
M: iwiped iright iwiped-sequence iright <iwiped> ;
M: iwiped ihead (ihead) ;
M: iwiped itail (itail) ;
M: iwiped $$ iwiped-sequence $$ dup quick-hash ;

M: object ## 
    dup i-length 0 < [ -- <i-wiped> -- ] [ <i-wiped> ] if ;
M: integer ## ;
M: ineg ## -- ## -- ;
M: irev ## `` ## `` ;
M: iwiped ## ;
