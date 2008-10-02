! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: sequences kernel arrays vectors accessors assocs sorting math math.functions ;

IN: math.binpack 

: (binpack) ( bins item -- )
    swap dup [ [ second ] map sum ] map swap zip sort-keys values first push ;

: binpack ( assoc n -- bins )
    [ sort-values reverse [ length ] keep swap ] dip 
    [ / ceiling ] keep swap <array> [ <vector> ] map 
    swap [ dupd (binpack) ] each ;

: binpack* ( items n -- bins )
    [ dup zip ] dip binpack [ keys ] map ;

: binpack! ( items quot n -- bins ) 
    [ dup ] 2dip [ map zip ] dip binpack [ keys ] map ;

