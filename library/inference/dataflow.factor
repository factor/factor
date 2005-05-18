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

: NODE:
    #! Followed by a node name.
    scan dup [ ] define-tuple
    create-in [ make-node ] define-constructor ; parsing

: empty-node f f f f f f f f f ;
: param-node ( label) f swap f f f f f ;
: in-d-node ( inputs) >r f f r> f f f f ;
: out-d-node ( outputs) >r f f f r> f f f ;

: d-tail ( n -- list ) meta-d get tail* >list ;
: r-tail ( n -- list ) meta-r get tail* >list ;

NODE: #label
: #label ( label -- node ) param-node <#label> ;

NODE: #call
: #call ( word -- node ) param-node <#call> ;

NODE: #call-label
: #call-label ( label -- node ) param-node <#call> ;

NODE: #push
: #push ( outputs -- node ) d-tail out-d-node <#push> ;

NODE: #drop
: #drop ( inputs -- node ) d-tail in-d-node <#drop> ;

NODE: #values
: #values ( -- node ) meta-d get >list in-d-node <#values> ;

NODE: #return
: #return ( -- node ) meta-d get >list in-d-node <#return> ;

NODE: #ifte
: #ifte ( in -- node ) 1 d-tail in-d-node <#ifte> ;

NODE: #dispatch
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

! Recursive state. An alist, mapping words to labels.
SYMBOL: recursive-state
