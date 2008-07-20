! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic assocs kernel math namespaces parser
sequences words vectors math.intervals effects classes
accessors combinators stack-checker.state ;
IN: compiler.tree

! High-level tree SSA form.
!
! Invariants:
! 1) Each value has exactly one definition. A "definition" means
! the value appears in the out-d or out-r slot of a node, or the
! values slot of an #introduce node.
! 2) Each value appears only once in the inputs of a node, where
! the inputs are the concatenation of in-d and in-r, or in the
! case of a #phi node, the sequence of sequences in the phi-in-r
! and phi-in-d slots.
! 3) A value is never used in the same node where it is defined.

TUPLE: node < identity-tuple
in-d out-d in-r out-r
classes literals intervals
history successor children ;

M: node hashcode* drop node hashcode* ;

: node-shuffle ( node -- shuffle )
    [ in-d>> ] [ out-d>> ] bi <effect> ;

: node-values ( node -- values )
    { [ in-d>> ] [ out-d>> ] [ in-r>> ] [ out-r>> ] } cleave
    4array concat ;

: node-child ( node -- child ) node-children first ;

: last-node ( node -- last )
    dup successor>> [ last-node ] [ ] ?if ;

: penultimate-node ( node -- penultimate )
    dup successor>> dup [
        dup successor>>
        [ nip penultimate-node ] [ drop ] if
    ] [
        2drop f
    ] if ;

: node-literal? ( node value -- ? )
    swap literals>> key? ;

: node-literal ( node value -- obj )
    swap literals>> at ;

: node-interval ( node value -- interval )
    swap intervals>> at ;

: node-class ( node value -- class )
    swap classes>> at ;

: node-input-classes ( node -- seq )
    dup in-d>> [ node-class ] with map ;

: node-output-classes ( node -- seq )
    dup out-d>> [ node-class ] with map ;

: node-input-intervals ( node -- seq )
    dup in-d>> [ node-interval ] with map ;

: node-class-first ( node -- class )
    dup in-d>> first node-class ;

TUPLE: #introduce < node values ;

: #introduce ( values -- node )
    \ #introduce new swap >>values ;

TUPLE: #call < node word ;

: #call ( inputs outputs word -- node )
    \ #call new
        swap >>word
        swap >>out-d
        swap >>in-d ;

TUPLE: #call-recursive < node label ;

: #call-recursive ( inputs outputs label -- node )
    \ #call-recursive new
        swap >>label
        swap >>out-d
        swap >>in-d ;

TUPLE: #push < node literal ;

: #push ( literal value -- node )
    \ #push new
        swap 1array >>out-d
        swap >>literal ;

TUPLE: #shuffle < node mapping ;

: #shuffle ( inputs outputs mapping -- node )
    \ #shuffle new
        swap >>mapping
        swap >>out-d
        swap >>in-d ;

: #drop ( inputs -- node )
    { } { } #shuffle ;

TUPLE: #>r < node ;

: #>r ( inputs outputs -- node )
    \ #>r new
        swap >>out-r
        swap >>in-d ;

TUPLE: #r> < node ;

: #r> ( inputs outputs -- node )
    \ #r> new
        swap >>out-d
        swap >>in-r ;

TUPLE: #terminate < node ;

: #terminate ( -- node ) \ #terminate new ;

TUPLE: #branch < node ;

: new-branch ( value children class -- node )
    new
        swap >>children
        swap 1array >>in-d ; inline

TUPLE: #if < #branch ;

: #if ( ? true false -- node )
    2array \ #if new-branch ;

TUPLE: #dispatch < #branch ;

: #dispatch ( n branches -- node )
    \ #dispatch new-branch ;

TUPLE: #phi < node phi-in-d phi-in-r ;

: #phi ( d-phi-in d-phi-out r-phi-in r-phi-out -- node )
    \ #phi new
        swap >>out-r
        swap >>phi-in-r
        swap >>out-d
        swap >>phi-in-d ;

TUPLE: #declare < node declaration ;

: #declare ( inputs outputs declaration -- node )
    \ #declare new
        swap >>declaration
        swap >>out-d
        swap >>in-d ;

TUPLE: #return < node label ;

: #return ( label stack -- node )
    \ #return new
        swap >>in-d
        swap >>label ;

TUPLE: #recursive < node word label loop? returns calls ;

: #recursive ( word label inputs outputs child -- node )
    \ #recursive new
        swap 1array >>children
        swap >>out-d
        swap >>in-d
        swap >>label
        swap >>word ;

TUPLE: #copy < node ;

: #copy ( inputs outputs -- node )
    \ #copy new
        swap >>out-d
        swap >>in-d ;

DEFER: #tail?

PREDICATE: #tail-phi < #phi successor>> #tail? ;

UNION: #tail POSTPONE: f #return #tail-phi #terminate ;
