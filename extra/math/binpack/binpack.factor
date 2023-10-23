! Copyright (C) 2008 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors assocs kernel math sequences sorting ;

IN: math.binpack

<PRIVATE

TUPLE: bin items total ;

: <bin> ( -- bin )
    V{ } clone 0 bin boa ; inline

: smallest-bin ( bins -- bin )
    [ total>> ] minimum-by ; inline

: add-to-bin ( item weight bin -- )
    [ + ] change-total items>> push ;

:: (binpack) ( alist #bins -- bins )
    alist sort-values <reversed> :> items
    #bins [ <bin> ] replicate :> bins
    items [ bins smallest-bin add-to-bin ] assoc-each
    bins [ items>> ] map ;

PRIVATE>

: binpack ( items #bins -- bins )
    [ dup zip ] dip (binpack) ;

: map-binpack ( items quot: ( item -- weight ) #bins -- bins )
    [ dupd map zip ] dip (binpack) ; inline
