! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: arrays generic hashtables interpreter kernel lists math
namespaces parser sequences words ;

! Recursive state. An alist, mapping words to labels.
SYMBOL: recursive-state

TUPLE: value recursion uid ;

C: value ( -- value )
    gensym over set-value-uid
    recursive-state get over set-value-recursion ;

M: value = eq? ;

M: value hashcode value-uid hashcode ;

TUPLE: literal value ;

C: literal ( obj -- value )
    <value> over set-delegate
    [ set-literal-value ] keep ;

M: literal hashcode delegate hashcode ;

! The dataflow IR is the first of the two intermediate
! representations used by Factor. It annotates concatenative
! code with stack flow information and types.

TUPLE: node param shuffle
       classes literals history
       successor children ;

M: node = eq? ;

: make-node ( param in-d out-d in-r out-r node -- node )
    [ >r swapd <shuffle> f f f f f <node> r> set-delegate ] keep ;

: node-in-d  node-shuffle shuffle-in-d  ;
: node-in-r  node-shuffle shuffle-in-r  ;
: node-out-d node-shuffle shuffle-out-d ;
: node-out-r node-shuffle shuffle-out-r ;

: set-node-in-d  node-shuffle set-shuffle-in-d  ;
: set-node-in-r  node-shuffle set-shuffle-in-r  ;
: set-node-out-d node-shuffle set-shuffle-out-d ;
: set-node-out-r node-shuffle set-shuffle-out-r ;

: empty-node f { } { } { } { } ;
: param-node ( label) { } { } { } { } ;
: in-node ( inputs) >r f r> { } { } { } ;
: out-node ( outputs) >r f { } r> { } { } ;

: d-tail ( n -- list ) meta-d get tail* ;
: r-tail ( n -- list ) meta-r get tail* ;

: node-child node-children first ;

TUPLE: #label ;
C: #label make-node ;
: #label ( label -- node ) param-node <#label> ;

TUPLE: #entry ;
C: #entry make-node ;
: #entry ( -- node ) meta-d get clone in-node <#entry> ;

TUPLE: #call ;
C: #call make-node ;
: #call ( word -- node ) param-node <#call> ;

TUPLE: #call-label ;
C: #call-label make-node ;
: #call-label ( label -- node ) param-node <#call-label> ;

TUPLE: #shuffle ;
C: #shuffle make-node ;
: #shuffle ( -- node ) empty-node <#shuffle> ;
: #push ( outputs -- node ) d-tail out-node <#shuffle> ;

TUPLE: #values ;
C: #values make-node ;
: #values ( -- node ) meta-d get clone in-node <#values> ;

TUPLE: #return ;
C: #return make-node ;
: #return ( label -- node )
    #! The parameter is the label we are returning from, or if
    #! f, this is a top-level return.
    meta-d get clone in-node <#return>
    [ set-node-param ] keep ;

TUPLE: #if ;
C: #if make-node ;
: #if ( in -- node ) 1 d-tail in-node <#if> ;

TUPLE: #dispatch ;
C: #dispatch make-node ;
: #dispatch ( in -- node ) 1 d-tail in-node <#dispatch> ;

TUPLE: #merge ;
C: #merge make-node ;
: #merge ( -- node ) meta-d get clone out-node <#merge> ;

TUPLE: #terminate ;
C: #terminate make-node ;
: #terminate ( -- node ) empty-node <#terminate> ;

: node-inputs ( d-count r-count node -- )
    tuck
    >r r-tail r> set-node-in-r
    >r d-tail r> set-node-in-d ;

: node-outputs ( d-count r-count node -- )
    tuck
    >r r-tail r> set-node-out-r
    >r d-tail r> set-node-out-d ;

! Variable holding dataflow graph being built.
SYMBOL: dataflow-graph
! The most recently added node.
SYMBOL: current-node

: node, ( node -- )
    dataflow-graph get [
        dup current-node [ set-node-successor ] change
    ] [
        ! first node
        dup dataflow-graph set  current-node set
    ] if ;

: nest-node ( -- dataflow current )
    dataflow-graph get  dataflow-graph off
    current-node get    current-node off ;

: unnest-node ( new-node dataflow current -- new-node )
    >r >r dataflow-graph get 1array over set-node-children
    r> dataflow-graph set
    r> current-node set ;

: with-nesting ( quot -- new-node | quot: -- new-node )
    nest-node 2slip unnest-node ; inline

: node-values ( node -- values )
    [
        dup node-in-d % dup node-out-d %
        dup node-in-r % node-out-r %
    ] { } make ;

: uses-value? ( value node -- ? ) node-values memq? ;

: outputs-value? ( value node -- ? )
    2dup node-out-d member? >r node-out-r member? r> or ;

: last-node ( node -- last )
    dup node-successor [ last-node ] [ ] ?if ;

: penultimate-node ( node -- penultimate )
    dup node-successor dup [
        dup node-successor
        [ nip penultimate-node ] [ drop ] if
    ] [
        2drop f
    ] if ;

: drop-inputs ( node -- #shuffle )
    node-in-d clone in-node <#shuffle> ;

: #drop ( n -- #shuffle )
    d-tail in-node <#shuffle> ;

: each-node ( node quot -- | quot: node -- )
    over [
        [ call ] 2keep swap
        [ node-children [ swap each-node ] each-with ] 2keep
        node-successor swap each-node
    ] [
        2drop
    ] if ; inline

: each-node-with ( obj node quot -- | quot: obj node -- )
    swap [ with ] each-node 2drop ; inline

: all-nodes? ( node quot -- ? | quot: node -- ? )
    over [
        [ call ] 2keep rot [
            [
                swap node-children [ swap all-nodes? ] all-with?
            ] 2keep rot [
                >r node-successor r> all-nodes?
            ] [
                2drop f
            ] if
        ] [
            2drop f
        ] if
    ] [
        2drop t
    ] if ; inline

: all-nodes-with? ( obj node quot -- ? | quot: obj node -- ? )
    swap [ with rot ] all-nodes? 2nip ; inline

: (subst-values) ( new old node -- )
    [ node-in-d subst ] 3keep [ node-in-r subst ] 3keep
    [ node-out-d subst ] 3keep node-out-r subst ;

: subst-values ( new old node -- )
    #! Mutates the node.
    [ >r 2dup r> (subst-values) ] each-node 2drop ;

: remember-node ( word node -- )
    #! Annotate each node with the fact it was inlined from
    #! 'word'.
    [
        dup #call?
        [ [ node-history ?push ] keep set-node-history ]
        [ 2drop ] if
    ] each-node-with ;

: (clone-node) ( node -- node )
    clone dup node-shuffle clone over set-node-shuffle ;

: clone-node ( node -- node )
    dup [
        (clone-node)
        dup node-children [ clone-node ] map over set-node-children
        dup node-successor clone-node over set-node-successor
    ] when ;

GENERIC: calls-label* ( label node -- ? )

M: node calls-label* 2drop f ;

M: #call-label calls-label* node-param eq? ;

: calls-label? ( label node -- ? )
    [ calls-label* not ] all-nodes-with? not ;

: recursive-label? ( node -- ? )
    dup node-param swap calls-label? ;
