! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: sequences kernel arrays vectors accessors assocs shuffle sorting locals math math.functions ;

IN: math.binpack 

: (binpack) ( bins item -- )
    [ [ values sum ] map ] keep
    zip sort-keys values first push ;

:: binpack ( assoc n -- bins )
    assoc sort-values <reversed> :> values
    values length :> #values
    n #values n / ceiling <array> [ <vector> ] map :> bins
    values [ bins (binpack) ] each
    bins ;

: binpack* ( items n -- bins )
    [ dup zip ] dip binpack [ keys ] map ;

: binpack! ( items quot n -- bins ) 
    [ dupd map zip ] dip binpack [ keys ] map ; inline

