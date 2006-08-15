! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: errors generic kernel math sequences-internals vectors ;

! A reversal of an underlying sequence.
TUPLE: reversed seq ;

: reversed@ reversed-seq [ length swap - 1- ] keep ; inline

M: reversed length reversed-seq length ;

M: reversed nth reversed@ nth ;

M: reversed nth-unsafe reversed@ nth-unsafe ;

M: reversed set-nth reversed@ set-nth ;

M: reversed set-nth-unsafe
    reversed@ set-nth-unsafe ;

M: reversed like reversed-seq like ;

M: reversed thaw reversed-seq thaw ;

: reverse ( seq -- seq ) [ <reversed> ] keep like ;

! A slice of another sequence.
TUPLE: slice seq from to ;

: collapse-slice ( from to slice -- from to seq )
    dup slice-from swap slice-seq >r tuck + >r + r> r> ;

TUPLE: slice-error reason ;
: slice-error ( str -- * ) <slice-error> throw ;

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

M: slice length
    dup slice-to swap slice-from - ;

: slice@ ( n slice -- n seq )
    [ slice-from + ] keep slice-seq ; inline

M: slice nth slice@ nth ;

M: slice nth-unsafe slice@ nth-unsafe ;

M: slice set-nth slice@ set-nth ;

M: slice set-nth-unsafe slice@ set-nth-unsafe ;

M: slice like slice-seq like ;

M: slice thaw slice-seq thaw ;
