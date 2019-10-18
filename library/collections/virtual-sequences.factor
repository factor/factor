! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: generic kernel math vectors ;

! A repeated sequence is the same element n times.
TUPLE: repeated length object ;

M: repeated length repeated-length ;

M: repeated nth nip repeated-object ;

! A reversal of an underlying sequence.
TUPLE: reversed ;

C: reversed [ set-delegate ] keep ;

: reversed@ delegate [ length swap - 1 - ] keep ;

M: reversed nth ( n seq -- elt ) reversed@ nth ;

M: reversed set-nth ( elt n seq -- ) reversed@ set-nth ;

M: reversed thaw ( seq -- seq ) delegate reverse ;

! A slice of another sequence.
TUPLE: slice seq from to step ;

: collapse-slice ( from to slice -- from to seq )
    dup slice-from swap slice-seq >r tuck + >r + r> r> ;

C: slice ( from to seq -- seq )
    #! A slice of a slice collapses.
    >r dup slice? [ collapse-slice ] when r>
    [ set-slice-seq ] keep
    >r 2dup > -1 1 ? r>
    [ set-slice-step ] keep
    [ set-slice-to ] keep
    [ set-slice-from ] keep ;

: <range> ( from to -- seq ) 0 <slice> ;

M: slice length ( range -- n )
    dup slice-to swap slice-from - abs ;

: slice@ ( n slice -- n seq )
    [ [ slice-step * ] keep slice-from + ] keep slice-seq ;

M: slice nth ( n slice -- obj ) slice@ nth ;

M: slice set-nth ( obj n slice -- ) slice@ set-nth ;

M: slice like ( seq slice -- seq ) slice-seq like ;
