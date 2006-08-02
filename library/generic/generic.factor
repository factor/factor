! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generic
USING: words kernel sequences namespaces ;

PREDICATE: compound generic ( word -- ? )
    "combination" word-prop ;

M: generic definer drop \ G: ;

: make-generic ( word -- )
    dup dup "combination" word-prop call define-compound ;

: ?make-generic ( word -- )
    bootstrapping? get
    [ [ ] define-compound ] [ make-generic ] if ;

: init-methods ( word -- )
     dup "methods" word-prop
     [ drop ] [ H{ } clone "methods" set-word-prop ] if ;

! Defining generic words

: bootstrap-combination ( quot -- quot )
    global [ [ dup word? [ target-word ] when ] map ] bind ;

: define-generic* ( word combination -- )
    bootstrap-combination
    dupd "combination" set-word-prop
    dup init-methods ?make-generic ;
