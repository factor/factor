! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: peg.ebnf math.parser kernel assocs sorting ;
IN: sorting.human

: find-numbers ( string -- seq )
    [EBNF Result = ([0-9]+ => [[ string>number ]] | (!([0-9]) .)+)* EBNF] ;

: human-sort ( seq -- seq' )
    [ dup find-numbers ] { } map>assoc sort-values keys ;
