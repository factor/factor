! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs kernel locals math sequences sorting ;

IN: math.binpack

<PRIVATE

TUPLE: bin items total ;

: <bin> ( -- bin )
    V{ } clone 0 bin boa ; inline

: smallest-bin ( bins -- bin )
    [ total>> ] infimum-by ; inline

: add-to-bin ( item weight bin -- )
    [ + ] change-total items>> push ;

:: (binpack) ( alist n-bins -- bins )
    alist sort-values <reversed> :> items
    n-bins [ <bin> ] replicate :> bins
    items [ bins smallest-bin add-to-bin ] assoc-each
    bins [ items>> ] map ;

PRIVATE>

: binpack ( items n-bins -- bins )
    [ dup zip ] dip (binpack) ;

: map-binpack ( items quot: ( item -- weight ) n-bins -- bins )
    [ dupd map zip ] dip (binpack) ; inline
