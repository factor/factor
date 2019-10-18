! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.order math.parser peg.ebnf
sequences sorting.functor ;
IN: sorting.human

: find-numbers ( string -- seq )
    [EBNF Result = ([0-9]+ => [[ string>number ]] | (!([0-9]) .)+)* EBNF] ;

! For comparing integers or sequences
TUPLE: hybrid obj ;

M: hybrid <=>
    [ obj>> ] bi@
    2dup [ integer? ] bi@ xor [
        drop integer? [ +lt+ ] [ +gt+ ] if
    ] [
        <=>
    ] if ;

<< "human" [ find-numbers [ hybrid boa ] map ] define-sorting >>
