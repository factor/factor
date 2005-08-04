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

! A range of integers.
TUPLE: range from to step ;

C: range ( from to -- range )
    >r 2dup > -1 1 ? r>
    [ set-range-step ] keep
    [ set-range-to ] keep
    [ set-range-from ] keep ;

M: range length ( range -- n )
    dup range-to swap range-from - abs ;

M: range nth ( n range -- n )
    [ range-step * ] keep range-from + ;

! A slice of another sequence.
TUPLE: slice seq ;

C: slice ( from to seq -- )
    [ set-slice-seq ] keep
    [ >r <range> r> set-delegate ] keep ;

M: slice nth ( n slice -- obj )
    [ delegate nth ] keep slice-seq nth ;

M: slice set-nth ( obj n slice -- )
    [ delegate nth ] keep slice-seq set-nth ;

M: slice like ( seq slice -- seq )
    slice-seq like ;
