! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs namespaces sequences kernel words ;
IN: inference.state

! Nesting state to solve recursion
SYMBOL: recursive-state

! Number of inputs current word expects from the stack
SYMBOL: d-in

! Compile-time data stack
SYMBOL: meta-d

: push-d ( obj -- ) meta-d get push ;
: pop-d  ( -- obj ) meta-d get pop ;
: peek-d ( -- obj ) meta-d get peek ;

! Compile-time retain stack
SYMBOL: meta-r

: push-r ( obj -- ) meta-r get push ;
: pop-r  ( -- obj ) meta-r get pop ;
: peek-r ( -- obj ) meta-r get peek ;

! Head of dataflow IR
SYMBOL: dataflow-graph

SYMBOL: current-node

! Words that the current dataflow IR depends on
SYMBOL: dependencies

: depends-on ( word how -- )
    swap dependencies get dup [
        2dup at +inlined+ eq? [ 3drop ] [ set-at ] if
    ] [ 3drop ] if ;

! Did the current control-flow path throw an error?
SYMBOL: terminated?

! Words we've inferred the stack effect of, for rollback
SYMBOL: recorded
