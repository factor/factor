! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.

IN: isequences.ops.iota
USING: generic kernel math sequences isequences.interface isequences.base ;



! **** positive iota ****
!

TUPLE: p-iota offset size ;

: <ip-iota> ( offset size -- p-iota ) 
    dup zero? [ nip ] [ dup 1 = [ drop <i> <i> ] [ <p-iota> ] if ] if ; inline

M: p-iota i-length p-iota-size ;
M: p-iota i-at swap p-iota-offset + <i> ;
M: p-iota ileft dup i-length 2/ >r p-iota-offset r> <ip-iota> ;
M: p-iota iright dup i-length 1 + 2/ >r dup p-iota-offset swap ileft i-length + r> <ip-iota> ;
M: p-iota ihead (ihead) ;
M: p-iota itail (itail) ;
M: p-iota $$ dup p-iota-offset swap p-iota-size [ $$ ] 2apply quick-hash ;
M: p-iota ascending? drop t ;
M: p-iota descending? drop f ;


! **** negative iota ****
!
TUPLE: n-iota offset size ;

: <in-iota> ( offset size -- n-iota ) 
    dup zero? [ nip ] [ dup 1 = [ drop <i> <i> ] [ <n-iota> ] if ] if ; inline

M: n-iota i-length n-iota-size ;
M: n-iota i-at swap n-iota-offset + neg -1 + <i> ;
M: n-iota ileft dup i-length 2/ >r n-iota-offset r> <in-iota> ;
M: n-iota iright dup i-length 1 + 2/ >r dup n-iota-offset swap ileft i-length + r> <in-iota> ;
M: n-iota ihead (ihead) ;
M: n-iota itail (itail) ;
M: n-iota $$ dup n-iota-offset swap n-iota-size [ $$ -- ] 2apply quick-hash ;
M: n-iota ascending? drop f ;
M: n-iota descending? drop t ; 

M: object ~~
    0 over i-length dup 0 <
    [ -- <in-iota> -- swap -- ## -- || ]
    [ <ip-iota> swap ## || ]
    if ;
M: integer ~~
    0 over 0 < [ swap -- <in-iota> -- ] [ swap <ip-iota> ] if ;
M: p-iota ~~ i-length ~~ ;
M: n-iota ~~ i-length ~~ ;
