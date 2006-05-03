! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer
USING: arrays generic hashtables inference kernel
kernel-internals lists math namespaces sequences words ;

! Some utilities for splicing in dataflow IR subtrees
: post-inline ( #return/#values #call/#merge -- )
    dup [
        [
            >r node-in-d r> node-out-d
            2array unify-lengths first2
        ] keep subst-values
    ] [
        2drop
    ] if ;

: subst-node ( old new -- )
    #! The last node of 'new' becomes 'old', then values are
    #! substituted. A subsequent optimizer phase kills the
    #! last node of 'new' and the first node of 'old'.
    last-node 2dup swap post-inline set-node-successor ;

: (inline-method) ( #call quot -- node )
    dup t eq? [
        2drop t
    ] [
        over node-in-d dataflow-with
        [ >r node-param r> remember-node ] 2keep
        [ subst-node ] keep [ infer-classes ] keep
    ] if ;

! Single dispatch method inlining optimization
: dispatch# ( #call -- n )
    node-param "combination" word-prop first ;

: dispatching-class ( node -- seq ) dup dispatch# node-class# ;

: already-inlined? ( node -- ? )
    #! Was this node inlined from definition of 'word'?
    dup node-param swap node-history memq? ;

: specific-method ( word class -- ? ) swap order min-class ;

: inlining-class ( #call -- class )
    #! If the generic dispatch can be eliminated, return the
    #! class of the method that will always be invoked here.
    dup node-param swap dispatching-class specific-method ;

: will-inline-method ( node -- quot/t )
    #! t indicates failure
    dup inlining-class dup [
        swap node-param "methods" word-prop hash
    ] [
        2drop t
    ] if ;

: inline-standard-method ( node -- node )
    dup will-inline-method (inline-method) ;

: inline-standard-method? ( #call -- ? )
    dup already-inlined? not swap node-param standard-generic?
    and ;

! Partial dispatch of 2generic words
: math-both-known? ( word left right -- ? )
    math-class-max specific-method ;

: max-tag ( class -- n ) types peek 1+ num-tags min ;

: left-partial-math ( word left right -- quot/t )
    #! The left type is known; dispatch on right
    \ dup swap max-tag
    [ >r 2dup r> math-method ] math-vtable* 2nip ;

: right-partial-math ( word left right -- quot/t )
    #! The right type is known; dispatch on left
    \ over rot max-tag
    [ >r 2dup r> swap math-method ] math-vtable* 2nip ;

: will-inline-math-method ( word left right -- quot/t )
    #! t indicates failure
    {
        { [ 3dup math-both-known? ] [ math-method ] }
        ! { [ 3dup drop specific-method ] [ left-partial-math ] }
        ! { [ 3dup nip specific-method ] [ right-partial-math ] }
        { [ t ] [ 3drop t ] }
    } cond ;

: inline-math-method ( #call -- node )
    dup node-param over 1 node-class# pick 0 node-class#
    will-inline-math-method (inline-method) ;

: inline-math-method? ( #call -- ? )
    dup node-history [ 2generic? ] contains? not
    swap node-param 2generic? and ;

: inline-method ( #call -- node )
    {
        { [ dup inline-standard-method? ] [ inline-standard-method ] }
        { [ dup inline-math-method? ] [ inline-math-method ] }
        { [ t ] [ drop t ] }
    } cond ;

! Resolve type checks at compile time where possible
: comparable? ( actual testing -- ? )
    #! If actual is a subset of testing or if the two classes
    #! are disjoint, return t.
    2dup class< >r classes-intersect? not r> or ;

: optimize-predicate? ( #call -- ? )
    dup node-param "predicating" word-prop dup [
        >r 0 node-class# r> comparable?
    ] [
        2drop f
    ] if ;

: inline-literals ( node literals -- node )
    #! Make #shuffle -> #push -> #return -> successor
    over drop-inputs [
        >r >list [ literalize ] map dataflow [ subst-node ] keep
        r> set-node-successor
    ] keep ;

: optimize-predicate ( #call -- node )
    dup node-param "predicating" word-prop >r
    dup 0 node-class# r> class< 1array inline-literals ;
