! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors db.tuples kernel new-slots semantic-db semantic-db.relations sequences sequences.deep ;
IN: semantic-db.hierarchy

TUPLE: tree id children ;
C: <tree> tree

: has-parent-relation ( -- relation-id )
    "has parent" relation-id ;

: parent-child* ( parent child -- arc-id )
    has-parent-relation spin create-arc* ;

: parent-child ( parent child -- )
    parent-child* drop ;

: un-parent-child ( parent child -- )
    has-parent-relation spin <arc> select-tuples [ id>> delete-arc ] each ;

: child-arcs ( node-id -- child-arcs )
    has-parent-relation f rot <arc> select-tuples ;

: children ( node-id -- children )
    child-arcs [ subject>> ] map ;

: parent-arcs ( node-id -- parent-arcs )
    has-parent-relation swap f <arc> select-tuples ;

: parents ( node-id -- parents )
     parent-arcs [ object>> ] map ;

: get-node-hierarchy ( node-id -- tree )
    dup children [ get-node-hierarchy ] map <tree> ;

: (get-root-nodes) ( node-id -- root-nodes/node-id )
    dup parents dup empty? [
        drop
    ] [
        nip [ (get-root-nodes) ] map
    ] if ;

: get-root-nodes ( node-id -- root-nodes )
    (get-root-nodes) flatten ;
