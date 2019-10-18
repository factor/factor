! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.

IN: isequences.ops.modulus
USING: generic kernel math sequences isequences.interface isequences.base ;


: %%g++ ( s1 s2 -- ms1 ms2 )
    2dup [ i-length ] 2apply 2dup [ 0 = ] 2apply or
    [ 3drop drop 0 0 ]
    [ 2dup mod -rot swap mod swap rot swap ihead >r ihead r> ] if ;

: %%g-+ ( s1 s2 -- ms1 ms2 )
    ;

: %%g+- ( s1 s2 -- ms2 ms2 )
    ;

: %%g-- ( s1 s2 -- ms1 ms2 )
    ;
    
: %%g ( s1 s2 --  ms1 ms2 )
    2dup [ neg? ] 2apply [ [ %%g-- ] [ %%g+- ] if ]
    [ [ %%g-+ ] [ %%g++ ] if ] if ; inline

M: object %% %%g ;
