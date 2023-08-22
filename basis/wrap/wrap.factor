! Copyright (C) 2009 Daniel Ehrenberg
! Copyright (C) 2017 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math sequences sequences.private ;
IN: wrap

TUPLE: element contents black white ;

C: <element> element

:: wrap ( elements width -- array )
    elements length integer>fixnum-strict :> #elements
    elements [ black>> ] { } map-as :> black
    elements [ white>> ] { } map-as :> white

    #elements 1 + f <array> :> minima
    #elements 1 + 0 <array> :> breaks

    0 0 minima set-nth-unsafe

    minima [| base i |
        0 i 1 + [ dup #elements <= ] [| j |
            j 1 - black nth-unsafe + dup :> w
            j 1 - white nth-unsafe +

            w width > [
                j 1 - i = [
                    0 j minima set-nth-unsafe
                    i j breaks set-nth-unsafe
                ] when #elements
            ] [
                base
                j #elements = [ width w - sq + ] unless :> cost
                j minima nth-unsafe [ cost >= ] [ t ] if* [
                    cost j minima set-nth-unsafe
                    i j breaks set-nth-unsafe
                ] when j
            ] if 1 +
        ] while 2drop
    ] each-index

    #elements [ dup 0 > ] [
        [ breaks nth dup ] keep elements <slice>
        [ contents>> ] map
    ] produce nip reverse ;
