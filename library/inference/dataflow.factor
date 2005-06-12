! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic interpreter kernel lists namespaces parser
sequences vectors words ;

! The dataflow IR is the first of the two intermediate
! representations used by Factor. It annotates concatenative
! code with stack flow information and types.

TUPLE: node effect param in-d out-d in-r out-r
       successor children ;

: make-node ( effect param in-d out-d in-r out-r node -- node )
    [ >r f <node> r> set-delegate ] keep ;

: empty-node f f f f f f f f f ;
: param-node ( label) f swap f f f f f ;
: in-d-node ( inputs) >r f f r> f f f f ;
: out-d-node ( outputs) >r f f f r> f f f ;

: d-tail ( n -- list ) meta-d get tail* >list ;
: r-tail ( n -- list ) meta-r get tail* >list ;

TUPLE: #label ;
C: #label make-node ;
: #label ( label -- node ) param-node <#label> ;

TUPLE: #call ;
C: #call make-node ;
: #call ( word -- node ) param-node <#call> ;

TUPLE: #call-label ;
C: #call-label make-node ;
: #call-label ( label -- node ) param-node <#call-label> ;

TUPLE: #push ;
C: #push make-node ;
: #push ( outputs -- node ) d-tail out-d-node <#push> ;

TUPLE: #drop ;
C: #drop make-node ;
: #drop ( inputs -- node ) d-tail in-d-node <#drop> ;

TUPLE: #values ;
C: #values make-node ;
: #values ( -- node ) meta-d get >list in-d-node <#values> ;

TUPLE: #return ;
C: #return make-node ;
: #return ( -- node ) meta-d get >list in-d-node <#return> ;

TUPLE: #ifte ;
C: #ifte make-node ;
: #ifte ( in -- node ) 1 d-tail in-d-node <#ifte> ;

TUPLE: #dispatch ;
C: #dispatch make-node ;
: #dispatch ( in -- node ) 1 d-tail in-d-node <#dispatch> ;

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
    >r >r dataflow-graph get unit over set-node-children
    r> dataflow-graph set
    r> current-node set ;

: with-nesting ( quot -- new-node | quot: -- new-node )
    nest-node 2slip unnest-node ; inline

: copy-effect ( from to -- )
    over node-in-d over set-node-in-d
    over node-in-r over set-node-in-r
    over node-out-d over set-node-out-d
    swap node-out-r swap set-node-out-r ;

: node-effect ( node -- [[ d-in meta-d ]] )
    dup node-in-d swap node-out-d cons ;

: consumes-literal? ( literal node -- ? )
    #! Does the dataflow node consume the literal?
    2dup node-in-d memq? >r node-in-r memq? r> or ;

: produces-literal? ( literal node -- ? )
    #! Does the dataflow node produce the literal?
    2dup node-out-d memq? >r node-out-r memq? r> or ;

: last-node ( node -- last )
    dup node-successor [ last-node ] [ ] ?ifte ;

! Recursive state. An alist, mapping words to labels.
SYMBOL: recursive-state
