! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.

IN: isequences.ops.cache
USING: generic kernel math sequences isequences.base isequences.interface ;

! ** An isequence that caches lazy values of its delegate isequence **

GENERIC: CC ( s -- cached-s )

TUPLE: icache left right size hash ;

: <i-cache> ( s -- cs )
    ! only cache isequences with size > 16
    dup i-length 16 > [ f f f f <icache> tuck set-delegate ] when ; inline
    
: cached-length ( s -- n )
    dup icache-size dup not
    [ drop dup delegate i-length tuck swap set-icache-size ]
    [ nip ] if ; inline
: cached-ileft ( s -- s ) 
    dup icache-left dup not
    [ drop dup delegate ileft CC tuck swap set-icache-left ]
    [ nip ] if ; inline
: cached-iright ( s -- s )
    dup icache-right dup not
    [ drop dup delegate iright CC tuck swap set-icache-right ]
    [ nip ] if ; inline
: cached-$$ ( s -- hash ) 
    dup icache-hash dup not
    [ drop dup delegate $$ tuck swap set-icache-hash ]
    [ nip ] if ; inline

M: object CC <i-cache> ;
M: integer CC ;
M: icache CC ;

M: icache i-at (i-at) ;
M: icache i-length cached-length ;
M: icache ileft cached-ileft ;
M: icache iright cached-iright ;
M: icache ihead (ihead) ;
M: icache itail (itail) ;
M: icache $$ ($$) ;

