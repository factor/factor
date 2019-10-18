! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer
USING: arrays generic hashtables kernel kernel-internals math
namespaces sequences vectors words strings ;

! Do stuff like dup foo? [ blah ] [ blah ] if
! So that in the common case where foo? holds, blah compiles
! more efficiently

: simple-specializer ( quot dispatch# classes -- quot )
    object add* swapd [ swap 2array ] map-with object
    method-alist>quot ;

: dispatch-specializer ( quot dispatch# n dispatcher -- quot )
    [ rot picker % , swap <array> , \ dispatch , ] [ ] make ;

: tag-specializer ( quot dispatch# -- quot )
    num-tags \ tag dispatch-specializer ;

: type-specializer ( quot dispatch# -- quot )
    num-types \ type dispatch-specializer ;

: make-specializer ( quot dispatch# spec -- quot )
    {
        { [ dup number eq? ] [ drop tag-specializer ] }
        { [ dup object eq? ] [ drop type-specializer ] }
        { [ dup \ * eq? ] [ 2drop ] }
        { [ dup array? ] [ simple-specializer ] }
        { [ t ] [ 1array simple-specializer ] }
    } cond ;

: specialized-def ( word -- quot )
    dup word-def swap "specializer" word-prop [
        [ length ] keep <reversed> [ make-specializer ] 2each
    ] when* ;
