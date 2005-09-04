! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic interpreter kernel lists namespaces parser
sequences vectors words ;

! Recursive state. An alist, mapping words to labels.
SYMBOL: recursive-state

TUPLE: value recursion uid ;

C: value ( -- value )
    gensym over set-value-uid
    recursive-state get over set-value-recursion ;

M: value = eq? ;

TUPLE: computed ;

C: computed ( -- value ) <value> over set-delegate ;

TUPLE: literal value ;

C: literal ( obj -- value )
    <value> over set-delegate
    [ set-literal-value ] keep ;

TUPLE: meet values ;

C: meet ( values -- value )
    <value> over set-delegate [ set-meet-values ] keep ;

: value-refers? ( referee referrer -- ? )
    2dup eq? [
        2drop t
    ] [
        dup meet? [
            meet-values [ value-refers? ] contains-with?
        ] [
            2drop f
        ] ifte
    ] ifte ;

! The dataflow IR is the first of the two intermediate
! representations used by Factor. It annotates concatenative
! code with stack flow information and types.

TUPLE: node param shuffle
       classes literals history
       successor children ;

M: node = eq? ;

: make-node ( param in-d out-d in-r out-r node -- node )
    [
        >r
        swapd <shuffle> {{ }} clone {{ }} clone { } clone f f <node>
        r>
        set-delegate
    ] keep ;

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
: in-d-node ( inputs) >r f r> { } { } { } ;
: out-d-node ( outputs) >r f { } r> { } { } ;

: d-tail ( n -- list ) meta-d get tail* ;
: r-tail ( n -- list ) meta-r get tail* ;

: node-child node-children first ;

TUPLE: #label ;
C: #label make-node ;
: #label ( label -- node ) param-node <#label> ;

TUPLE: #entry ;
C: #entry make-node ;
: #entry ( -- node ) meta-d get clone in-d-node <#entry> ;

TUPLE: #call ;
C: #call make-node ;
: #call ( word -- node ) param-node <#call> ;

TUPLE: #call-label ;
C: #call-label make-node ;
: #call-label ( label -- node ) param-node <#call-label> ;

TUPLE: #push ;
C: #push make-node ;
: #push ( outputs -- node ) d-tail out-d-node <#push> ;

TUPLE: #shuffle ;
C: #shuffle make-node ;
: #shuffle ( -- node ) empty-node <#shuffle> ;

TUPLE: #values ;
C: #values make-node ;
: #values ( -- node ) meta-d get clone in-d-node <#values> ;

TUPLE: #return ;
C: #return make-node ;
: #return ( -- node ) meta-d get clone in-d-node <#return> ;

TUPLE: #ifte ;
C: #ifte make-node ;
: #ifte ( in -- node ) 1 d-tail in-d-node <#ifte> ;

TUPLE: #dispatch ;
C: #dispatch make-node ;
: #dispatch ( in -- node ) 1 d-tail in-d-node <#dispatch> ;

TUPLE: #merge ;
C: #merge make-node ;
: #merge ( -- node ) meta-d get clone out-d-node <#merge> ;

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
    ] ifte ;

: nest-node ( -- dataflow current )
    dataflow-graph get  dataflow-graph off
    current-node get    current-node off ;

: unnest-node ( new-node dataflow current -- new-node )
    >r >r dataflow-graph get 1vector over set-node-children
    r> dataflow-graph set
    r> current-node set ;

: with-nesting ( quot -- new-node | quot: -- new-node )
    nest-node 2slip unnest-node ; inline

: node-effect ( node -- [[ d-in meta-d ]] )
    dup node-in-d swap node-out-d cons ;

: node-values ( node -- values )
    [
        dup node-in-d % dup node-out-d %
        dup node-in-r % node-out-r %
    ] { } make ;

: uses-value? ( value node -- ? )
    node-values [ value-refers? ] contains-with? ;

: outputs-value? ( value node -- ? )
    2dup node-out-d member? >r node-out-r member? r> or ;

: last-node ( node -- last )
    dup node-successor [ last-node ] [ ] ?ifte ;

: penultimate-node ( node -- penultimate )
    dup node-successor dup [
        dup node-successor
        [ nip penultimate-node ] [ drop ] ifte
    ] [
        2drop f
    ] ifte ;

: drop-inputs ( node -- #shuffle )
    node-in-d clone in-d-node <#shuffle> ;

: #drop ( n -- #shuffle )
    d-tail in-d-node <#shuffle> ;

: each-node ( node quot -- | quot: node -- )
    over [
        [ call ] 2keep swap
        [ node-children [ swap each-node ] each-with ] 2keep
        node-successor swap each-node
    ] [
        2drop
    ] ifte ; inline

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
            ] ifte
        ] [
            2drop f
        ] ifte
    ] [
        2drop t
    ] ifte ; inline

: all-nodes-with? ( obj node quot -- ? | quot: obj node -- ? )
    swap [ with rot ] all-nodes? 2nip ; inline

SYMBOL: substituted

DEFER: subst-value

: subst-meet ( new old meet -- )
    #! We avoid mutating the same meet more than once, since
    #! doing so can introduce cycles.
    dup substituted get memq? [
        3drop
    ] [
        dup substituted get push meet-values subst-value
    ] ifte ;

: (subst-value) ( new old value -- value )
    2dup eq? [
        2drop
    ] [
        dup meet? [
            pick over swap value-refers? [
                2nip ! don't substitute a meet into itself
            ] [
                [ subst-meet ] keep
            ] ifte
        ] [
            2nip
        ] ifte
    ] ifte ;

: subst-value ( new old seq -- )
    pick pick eq? over empty? or [
        3drop
    ] [
        [ >r 2dup r> (subst-value) ] nmap 2drop
    ] ifte ;

: (subst-values) ( newseq oldseq seq -- )
    #! Mutates seq.
    -rot [ pick subst-value ] 2each drop ;

: subst-values ( new old node -- )
    #! Mutates the node.
    [
        { } clone substituted set [
            3dup node-in-d  (subst-values)
            3dup node-in-r  (subst-values)
            3dup node-out-d (subst-values)
            3dup node-out-r (subst-values)
            drop
        ] each-node 2drop
    ] with-scope ;

: remember-node ( word node -- )
    #! Annotate each node with the fact it was inlined from
    #! 'word'.
    [
        dup #call? [ node-history push ] [ 2drop ] ifte
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
