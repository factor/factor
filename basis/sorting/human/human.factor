! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math.parser peg.ebnf sorting.functor ;
IN: sorting.human

: find-numbers ( string -- seq )
    [EBNF Result = ([0-9]+ => [[ string>number ]] | (!([0-9]) .)+)* EBNF] ;

<< "human" [ find-numbers ] define-sorting >>
