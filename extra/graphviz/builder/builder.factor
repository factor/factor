! Copyright (C) 2011 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes classes.tuple combinators kernel
sequences strings summary words
graphviz
graphviz.attributes
graphviz.ffi
;
IN: graphviz.builder

! Errors

ERROR: non-graph-error obj ;

M: non-graph-error summary
    drop "build-alien must be applied to the root graph" ;


ERROR: improper-statement-error obj ;

M: improper-statement-error summary
    drop "Not a proper Graphviz statement" ;

! Use FFI to construct Agraph_t equivalent of a graph object

<PRIVATE

GENERIC: (build-alien) ( Agraph_t* obj -- )

M: object (build-alien) improper-statement-error ;

! Attributes

: build-alien-attr ( alien attr value -- alien )
    dup
    [ [ "" agsafeset drop ] 3keep 2drop ]
    [ 2drop ]
    if ; inline

: build-alien-attrs ( alien attrs -- )
    [ class "slots" word-prop ] [ tuple>array rest ] bi
    [ [ name>> ] dip build-alien-attr ] 2each drop ;

M: graph-attributes (build-alien)
    build-alien-attrs ;
M: node-attributes (build-alien)
    [ agprotonode ] dip build-alien-attrs ;
M: edge-attributes (build-alien)
    [ agprotoedge ] dip build-alien-attrs ;

! Subgraphs

: build-alien-subgraph ( alien-graph subgraph -- alien-subgraph )
    [ id>> agsubg dup ] [ statements>> ] bi
    [ (build-alien) ] with each ;

M: subgraph (build-alien) build-alien-subgraph drop ;

! Nodes

M: node (build-alien)
    [ id>> agnode ]
    [ attributes>> build-alien-attrs ] bi ;

! Edges

GENERIC: build-alien-endpoint ( Agraph_t* obj -- alien )

M: string   build-alien-endpoint agnode ;
M: subgraph build-alien-endpoint build-alien-subgraph ;

: build-alien-endpoints ( Agraph_t* edge -- Agraph_t* tail head )
    [ dup ] dip
    [ tail>> build-alien-endpoint ]
    [ head>> build-alien-endpoint ] 2bi ;


: node->node? ( tail head -- ? )
    [ string? ] [ string? ] bi* and ; inline

: node->subg? ( tail head -- ? )
    [ string? ] [ subgraph? ] bi* and ; inline

: subg->node? ( tail head -- ? )
    [ subgraph? ] [ string? ] bi* and ; inline

: subg->subg? ( tail head -- ? )
    [ subgraph? ] [ subgraph? ] bi* and ; inline


: node->node ( Agraph_t* tail head attrs -- Agraph_t* )
    [ dup ] 3dip
    [ agedge ] dip build-alien-attrs ;

: node->subg ( Agraph_t* tail head attrs -- Agraph_t* )
    [ node->node ] curry with each-node ;

: subg->node ( Agraph_t* tail head attrs -- Agraph_t* )
    [ node->node ] 2curry each-node ;

: subg->subg ( Agraph_t* tail head attrs -- Agraph_t* )
    [ node->subg ] 2curry each-node ;


M: edge (build-alien)
    [ build-alien-endpoints ] 2keep nip
    [ attributes>> ] [ tail>> ] [ head>> ] tri
    {
        { [ 2dup node->node? ] [ 2drop node->node ] }
        { [ 2dup node->subg? ] [ 2drop node->subg ] }
        { [ 2dup subg->node? ] [ 2drop subg->node ] }
        { [ 2dup subg->subg? ] [ 2drop subg->subg ] }
    } cond drop ;

PRIVATE>

! Main word

GENERIC: build-alien ( Agraph_t* graph -- )

M: graph build-alien statements>> [ (build-alien) ] with each ;

M: object build-alien non-graph-error ;
