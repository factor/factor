! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: interpreter kernel lists namespaces sequences vectors
words ;

! Recursive state. An alist, mapping words to labels.
SYMBOL: recursive-state

! We build a dataflow graph for the compiler.
SYMBOL: dataflow-graph

! Label nodes have the node-label variable set.
SYMBOL: #label

SYMBOL: #call ( non-tail call )
SYMBOL: #call-label
SYMBOL: #push ( literal )
SYMBOL: #drop

! This is purely a marker for values we retain after a
! conditional. It does not generate code, but merely alerts the
! dataflow optimizer to the fact these values must be retained.
SYMBOL: #values

SYMBOL: #return

SYMBOL: node-consume-d
SYMBOL: node-produce-d
SYMBOL: node-consume-r
SYMBOL: node-produce-r
SYMBOL: node-op
SYMBOL: node-label

! #push nodes have this field set to the value being pushed.
! #call nodes have this as the word being called
SYMBOL: node-param

: <dataflow-node> ( param op -- node )
    <namespace> [
        node-op set
        node-param set
        [ ] node-consume-d set
        [ ] node-produce-d set
        [ ] node-consume-r set
        [ ] node-produce-r set
    ] extend ;

: node-inputs ( d-count r-count -- )
    #! Execute in the node's namespace.
    meta-r get vector-tail* node-consume-r set
    meta-d get vector-tail* node-consume-d set ;

: dataflow-inputs ( in node -- )
    [ length 0 node-inputs ] bind ;

: node-outputs ( d-count r-count -- )
    #! Execute in the node's namespace.
    meta-r get vector-tail* node-produce-r set
    meta-d get vector-tail* node-produce-d set ;

: dataflow-outputs ( out node -- )
    [ length 0 node-outputs ] bind ;

: get-dataflow ( -- IR )
    dataflow-graph get reverse ;

: dataflow, ( param op -- node )
    #! Add a node to the dataflow IR.
    <dataflow-node> dup dataflow-graph [ cons ] change ;

: dataflow-drop, ( n -- )
    f #drop dataflow, [ 0 node-inputs ] bind ;

: dataflow-push, ( n -- )
    f #push dataflow, [ 0 node-outputs ] bind ;

: apply-dataflow ( dataflow name default -- )
    #! For the dataflow node, look up named word property,
    #! if its not defined, apply default quotation to
    #! ( node ) otherwise apply property quotation to
    #! ( node ).
    >r >r dup [ node-op get ] bind r> word-prop dup [
        call r> drop
    ] [
        drop r> call
    ] ifte ;
