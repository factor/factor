! Copyright (C) 2011 Alex Vondrak.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays grouping kernel namespaces present
sequences strings
graphviz.attributes
;
IN: graphviz

TUPLE: graph
{ id string }
{ strict? boolean }
{ directed? boolean }
statements ;

TUPLE: subgraph
{ id string }
statements ;

TUPLE: node
{ id string }
{ attributes node-attributes } ;

TUPLE: edge
tail
head
{ attributes edge-attributes } ;

! Constructors

<PRIVATE

: anon-id ( -- id )
    \ anon-id counter present "_anonymous_" prepend ; inline

PRIVATE>

: <graph> ( -- graph )
    anon-id f f V{ } clone graph boa ;

: <strict-graph> ( -- graph )
    <graph> t >>strict? ;

: <digraph> ( -- graph )
    <graph> t >>directed? ;

: <strict-digraph> ( -- graph )
    <digraph> t >>strict? ;

: <anon> ( -- subgraph )
    anon-id V{ } clone subgraph boa ;

: <subgraph> ( id -- subgraph )
    present V{ } clone subgraph boa ;

: <cluster> ( id -- subgraph )
    present "cluster_" prepend V{ } clone subgraph boa ;

: <node> ( id -- node )
    present <node-attributes> node boa ;

DEFER: add-nodes

: <edge> ( tail head -- edge )
    [
        dup array?
        [ <anon> swap add-nodes ]
        [ dup subgraph? [ present ] unless ]
        if
    ] bi@
    <edge-attributes> edge boa ;

! Building graphs

: add ( graph statement -- graph' )
    over statements>> push ;

: add-node ( graph id -- graph' )
    <node> add ; inline

: add-edge ( graph tail head -- graph' )
    <edge> add ; inline

: add-nodes ( graph nodes -- graph' )
    [ add-node ] each ;

: add-path ( graph nodes -- graph' )
    2 <clumps> [ first2 add-edge ] each ;
