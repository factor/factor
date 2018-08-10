! Copyright (C) 2009 Daniel Ehrenberg
! Copyright (C) 2017 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel locals math sequences
sequences.private ;
IN: wrap

TUPLE: element contents black white ;

C: <element> element

:: wrap ( elements width -- array )
    elements length integer>fixnum-strict :> n-elements
    elements [ black>> ] { } map-as :> black
    elements [ white>> ] { } map-as :> white

    n-elements 1 + f <array> :> minima
    n-elements 1 + 0 <array> :> breaks

    0 0 minima set-nth-unsafe

    minima |[ base i |
        0 i 1 + [ dup n-elements <= ] |[ j |
            j 1 - black nth-unsafe + dup :> w
            j 1 - white nth-unsafe +

            w width > [
                j 1 - i = [
                    0 j minima set-nth-unsafe
                    i j breaks set-nth-unsafe
                ] when n-elements
            ] [
                base
                j n-elements = [ width w - sq + ] unless :> cost
                j minima nth-unsafe [ cost >= ] [ t ] if* [
                    cost j minima set-nth-unsafe
                    i j breaks set-nth-unsafe
                ] when j
            ] if 1 +
        ] while 2drop
    ] each-index

    n-elements [ dup 0 > ] [
        [ breaks nth dup ] keep elements <slice>
        [ contents>> ] map
    ] produce nip reverse ;
