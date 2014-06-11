! Copyright (C) 2014 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs heaps kernel sequences ;

IN: sorting.heap

<PRIVATE

: (heapsort) ( alist accum -- sorted-seq )
    [ >min-heap ] [ [ [ push ] curry slurp-heap ] keep ] bi* ; inline

PRIVATE>

: heapsort ( seq -- sorted-seq )
    [
        [ dup zip ]
        [ length ]
        [ new-resizable ] tri
        (heapsort)
    ] [ like ] bi ;

: heapsort-with ( seq quot: ( elt -- key ) -- sorted-seq )
    [
        [ keep ] curry [ { } map>assoc ] curry
        [ length ]
        [ new-resizable ] tri
        (heapsort)
    ] 2keep drop like ; inline
