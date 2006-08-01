! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: errors generic kernel math sequences-internals vectors ;

! A reversal of an underlying sequence.
TUPLE: reversed seq ;

: reversed@ reversed-seq [ length swap - 1- ] keep ; inline

M: reversed length ( seq -- n ) reversed-seq length ;

M: reversed nth ( n seq -- elt ) reversed@ nth ;

M: reversed nth-unsafe ( n seq -- elt ) reversed@ nth-unsafe ;

M: reversed set-nth ( elt n seq -- ) reversed@ set-nth ;

M: reversed set-nth-unsafe ( elt n seq -- )
    reversed@ set-nth-unsafe ;

M: reversed like ( seq reversed -- seq ) reversed-seq like ;

M: reversed thaw ( seq -- seq ) reversed-seq thaw ;

: reverse ( seq -- seq ) [ <reversed> ] keep like ;

! A slice of another sequence.
TUPLE: slice seq from to ;

: collapse-slice ( from to slice -- from to seq )
    dup slice-from swap slice-seq >r tuck + >r + r> r> ;

TUPLE: slice-error reason ;
: slice-error ( str -- ) <slice-error> throw ;

: check-slice ( from to seq -- )
    pick 0 < [ "start < 0" slice-error ] when
    length over < [ "end > sequence" slice-error ] when
    > [ "start > end" slice-error ] when ;

C: slice ( from to seq -- seq )
    #! A slice of a slice collapses.
    >r dup slice? [ collapse-slice ] when r>
    >r 3dup check-slice r>
    [ set-slice-seq ] keep
    [ set-slice-to ] keep
    [ set-slice-from ] keep ;

M: slice length ( range -- n )
    dup slice-to swap slice-from - ;

: slice@ ( n slice -- n seq )
    [ slice-from + ] keep slice-seq ; inline

M: slice nth ( n slice -- obj ) slice@ nth ;

M: slice nth-unsafe ( n slice -- obj ) slice@ nth-unsafe ;

M: slice set-nth ( obj n slice -- ) slice@ set-nth ;

M: slice set-nth-unsafe ( n slice -- obj ) slice@ set-nth-unsafe ;

M: slice like ( seq slice -- seq ) slice-seq like ;

M: slice thaw ( seq -- seq ) slice-seq thaw ;
