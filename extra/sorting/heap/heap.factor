! Copyright (C) 2014 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: heaps kernel sequences vectors ;

IN: sorting.heap

: heapsort-with ( seq quot: ( elt -- key ) -- sorted-seq )
    [
        over length <vector> min-heap boa
        [ '[ dup @ _ heap-push ] each ] keep
    ] [
        drop [ length ] keep new-resizable
        [ '[ drop _ push ] slurp-heap ] keep
    ] [
        drop like
    ] 2tri ; inline

: heapsort ( seq -- sorted-seq ) [ ] heapsort-with ;
