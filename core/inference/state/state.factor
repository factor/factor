! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs namespaces sequences kernel ;
IN: inference.state

! Nesting state to solve recursion
SYMBOL: recursive-state

! Number of inputs current word expects from the stack
SYMBOL: d-in

! Compile-time data stack
SYMBOL: meta-d

: push-d meta-d get push ;
: pop-d meta-d get pop ;
: peek-d meta-d get peek ;

! Compile-time retain stack
SYMBOL: meta-r

: push-r meta-r get push ;
: pop-r meta-r get pop ;
: peek-r meta-r get peek ;

! Head of dataflow IR
SYMBOL: dataflow-graph

SYMBOL: current-node

! Words that the current dataflow IR depends on
SYMBOL: dependencies

SYMBOL: +inlined+
SYMBOL: +called+

: depends-on ( word how -- )
    swap dependencies get dup [
        2dup at +inlined+ eq? [ 3drop ] [ set-at ] if
    ] [ 3drop ] if ;

: computing-dependencies ( quot -- dependencies )
    H{ } clone [ dependencies rot with-variable ] keep ;
    inline

! Did the current control-flow path throw an error?
SYMBOL: terminated?

! Words we've inferred the stack effect of, for rollback
SYMBOL: recorded
