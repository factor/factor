! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: sequences kernel arrays vectors accessors assocs sorting math math.functions ;

IN: math.binpack 

: (binpack) ( bins item -- )
    [ [ values sum ] map ] keep
    zip sort-keys values first push ;

: binpack ( assoc n -- bins )
    [ sort-values <reversed> dup length ] dip
    tuck / ceiling <array> [ <vector> ] map
    tuck [ (binpack) ] curry each ;

: binpack* ( items n -- bins )
    [ dup zip ] dip binpack [ keys ] map ;

: binpack! ( items quot n -- bins ) 
    [ dupd map zip ] dip binpack [ keys ] map ; inline

