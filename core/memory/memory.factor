! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel continuations sequences vectors arrays system math ;
IN: memory

: (each-object) ( quot: ( obj -- ) -- )
    next-object dup [
        swap [ call ] keep (each-object)
    ] [ 2drop ] if ; inline recursive

: each-object ( quot -- )
    gc begin-scan [ (each-object) ] [ end-scan ] [ ] cleanup ; inline

: count-instances ( quot -- n )
    0 swap [ 1 0 ? + ] compose each-object ; inline

: instances ( quot -- seq )
    #! To ensure we don't need to grow the vector while scanning
    #! the heap, we do two scans, the first one just counts the
    #! number of objects that satisfy the predicate.
    [ count-instances 100 + <vector> ] keep swap
    [ [ push-if ] 2curry each-object ] keep >array ; inline

: save ( -- ) image save-image ;
