! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: peg.ebnf math.parser kernel assocs sorting fry
math.order sequences ascii splitting.monotonic ;
IN: sorting.human

: find-numbers ( string -- seq )
    [EBNF Result = ([0-9]+ => [[ string>number ]] | (!([0-9]) .)+)* EBNF] ;

: human<=> ( obj1 obj2 -- <=> ) [ find-numbers ] bi@ <=> ;

: human>=< ( obj1 obj2 -- >=< ) human<=> invert-comparison ; inline

: human-compare ( obj1 obj2 quot -- <=> ) bi@ human<=> ; inline

: human-sort ( seq -- seq' ) [ human<=> ] sort ;

: human-sort-keys ( seq -- sortedseq )
    [ [ first ] human-compare ] sort ;

: human-sort-values ( seq -- sortedseq )
    [ [ second ] human-compare ] sort ;
