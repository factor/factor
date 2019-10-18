! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generic
USING: words kernel sequences namespaces assocs hashtables
definitions ;

PREDICATE: compound generic ( word -- ? )
    "combination" word-prop ;

M: generic definer drop \ G: \ ; ;

M: generic definition "combination" word-prop ;

: make-generic ( word -- )
    dup dup "combination" word-prop call define-compound ;

: ?make-generic ( word -- )
    [ [ ] define-compound ] [ make-generic ] if-bootstrapping ;

: init-methods ( word -- )
     dup "methods" word-prop
     ?<hashtable>
     "methods" set-word-prop ;

! Defining generic words

: bootstrap-combination ( quot -- quot )
    global [ [ dup word? [ target-word ] when ] map ] bind ;

: define-generic ( word combination -- )
    bootstrap-combination
    dupd "combination" set-word-prop
    dup init-methods ?make-generic ;

: generic-tags ( word -- seq )
    "methods" word-prop keys [ types ] map concat prune ;
