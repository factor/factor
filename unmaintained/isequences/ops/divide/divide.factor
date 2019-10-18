! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.

IN: isequences.ops.divide
USING: generic kernel math math.functions sequences isequences.interface isequences.base ;


TUPLE: idiv sequence div offset size ;

: n-cut ( seq pos -- seq )
    2dup ihead -rot itail <isequence> ; inline
    
: n-div ( seq div -- seq )
    swap dup i-length 2/ dup roll mod - n-cut ; inline

: <i-div> ( sequence div offset size -- idiv )
    pick 1 = 
    [ 3drop ] [ >r >r tuck n-div swap r> r> <idiv> ] if ; inline

: idiv-unpack ( idiv -- sequence div offset size )
    dup idiv-sequence swap dup idiv-div swap dup idiv-offset swap idiv-size ; inline
    
: (idiv-offset) ( pos idiv -- offset-pos )
    tuck dup idiv-offset swap idiv-div
    dup * -rot + * swap idiv-size 2dup
    mod neg rot + swap /i ; inline

: (idiv-index) ( pos idiv -- index )
    idiv-div * ; inline

: idiv-nth ( idiv pos -- v )
    swap tuck 2dup (idiv-index) -rot (idiv-offset)
    + swap idiv-sequence swap i-at ; inline

: idiv-ileft ( idiv -- idiv )
    dup idiv-sequence ileft swap dup idiv-div
    pick i-length swap tuck = 
    [ drop nip 0 i-at <i> ]
    [ swap dup idiv-offset swap idiv-size <i-div> ]
    if ;

: (idiv-newoffset) ( idiv -- newoff )
    dup ileft i-length swap idiv-offset + ;

: idiv-iright ( idiv -- idiv )
    dup idiv-sequence iright swap dup idiv-div
    pick i-length swap tuck =
    [ drop nip dup ileft i-length i-at <i> ]
    [ swap dup (idiv-newoffset) swap idiv-size <i-div> ]
    if ; inline 
   
M: idiv i-length dup idiv-sequence i-length swap idiv-div /i ;
M: idiv i-at idiv-nth ;
M: idiv ileft idiv-ileft ;
M: idiv iright idiv-iright ;
M: idiv ihead (ihead) ;
M: idiv itail (itail) ;
M: idiv $$
    idiv-unpack [ $$ ] 2apply quick-hash -rot [ $$ ]
    2apply [ quick-hash ] 2apply ;

: gcd_0 ( n1 n2 -- n )
    dup zero? [ 2drop 1 ] [ gcd ] if ; inline
    
: /_g++ ( s1 n -- idiv )
    i-length over i-length tuck gcd_0 0 rot <i-div> ; inline

: /_g+- ( s n -- s ) -- /_ ; inline

: /_g-+ ( s n -- s ) swap -- `` swap /_ -- `` ; inline

: /_g-- ( s n -- s ) [ -- ] 2apply /_ ; inline

: /_g ( s1 s2 -- s )
    2dup [ neg? ] 2apply [ [ /_g-- ] [ /_g+- ] if ] [ [ /_g-+ ] [ /_g++ ] if ] if ; inline
 
M: object /_ /_g ;


: _/g++ ( n s -- s )
    dup i-length dup roll i-length gcd_0 tuck /i tuck roll _* rot /_ swap /_ ;

: _/g+- ( n s -- s ) -- `` _/ `` -- ; inline

: _/g-+ ( n s -- s ) swap -- swap _/ ; inline

: _/g-- ( n s -- s ) [ -- ] 2apply _/ ; inline

: _/g ( n s -- s )
    2dup [ neg? ] 2apply [ [ _/g-- ] [ _/g+- ] if ]
    [ [ _/g-+ ] [ _/g++ ] if ] if ; inline

M: object _/ _/g ;

