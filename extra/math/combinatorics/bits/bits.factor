! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: kernel math math.bitwise sequences ;
IN: math.combinatorics.bits

: next-permutation-bits ( v -- w )
    [ dup 1 - bitor 1 + dup ] keep
    [ dup neg bitand ] bi@ /i 2/ 1 - bitor ;

<PRIVATE

: permutation-bits-quot ( bit-count bits quot -- n pred body )
    [ [ on-bits dup '[ dup _ >= ] ] [ on-bits ] bi* ] dip swap
    '[ _ [ next-permutation-bits _ bitand ] bi ] ; inline

PRIVATE>

: each-permutation-bits ( ... bit-count bits quot: ( ... n -- ... ) -- ... )
    permutation-bits-quot while drop ; inline

: map-permutation-bits ( ... bit-count bits quot: ( ... n -- ... m ) -- ... seq )
    permutation-bits-quot [ swap ] compose produce nip ; inline

: filter-permutation-bits ( ... bit-count bits quot: ( ... n -- ... ? ) -- ... seq )
    selector [ each-permutation-bits ] dip ; inline

: all-permutation-bits ( bit-count bits -- seq )
    [ ] map-permutation-bits ;

: find-permutation-bits ( ... bit-count bits quot: ( ... n -- ... ? ) -- ... elt/f )
    [ f f ] 3dip [ 2nip ] prepose [ keep swap ] curry
    permutation-bits-quot [ [ pick not and ] compose ] dip
    while drop swap and ; inline

: reduce-permutation-bits ( ... bit-count bits identity quot: ( ... prev elt -- ... next ) -- ... result )
    -rotd each-permutation-bits ; inline
