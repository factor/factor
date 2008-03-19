! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays continuations db db.tuples db.types db.sqlite hashtables kernel math math.parser namespaces new-slots sequences sequences.deep sequences.lib ;
IN: semantic-db

TUPLE: node id content ;
: <node> ( content -- node )
    node construct-empty swap >>content ;

: <id-node> ( id -- node )
    node construct-empty swap >>id ;

node "node"
{
    { "id" "id" +native-id+ +autoincrement+ }
    { "content" "content" TEXT }
} define-persistent

: create-node-table ( -- )
    node create-table ;

: delete-node ( node-id -- )
    <id-node> delete-tuple ;

: create-node ( str -- node-id )
    <node> dup insert-tuple id>> ;

: node-content ( id -- str )
    f <node> swap >>id select-tuple content>> ;

TUPLE: arc id subject object relation ;

: <arc> ( subject object relation -- arc )
    arc construct-empty swap >>relation swap >>object swap >>subject ;

: <id-arc> ( id -- arc )
    arc construct-empty swap >>id ;

: insert-arc ( arc -- )
    f <node> dup insert-tuple id>> >>id insert-tuple ;

: delete-arc ( arc-id -- )
    dup delete-node <id-arc> delete-tuple ;

: create-arc ( subject object relation -- arc-id )
    <arc> dup insert-arc id>> ;

arc "arc"
{
    { "id" "id" INTEGER +assigned-id+ } ! foreign key to node table?
    { "relation" "relation" INTEGER +not-null+ }
    { "subject" "subject" INTEGER +not-null+ }
    { "object" "object" INTEGER +not-null+ }
} define-persistent

: create-arc-table ( -- ) arc create-table ;

: create-bootstrap-nodes ( -- )
    "semantic-db" create-node drop
    "has context" create-node drop ;

: semantic-db-context 1 ;
: has-context-relation 2 ;

: create-bootstrap-arcs ( -- )
    has-context-relation semantic-db-context has-context-relation create-arc drop ;

: init-semantic-db ( -- )
    create-node-table create-arc-table create-bootstrap-nodes create-bootstrap-arcs ;

: param ( value key type -- param )
    swapd 3array ;

: single-int-results ( bindings sql -- array )
    f f <simple-statement> [ do-bound-query ] with-disposal
    [ first string>number ] map ;

: ensure2 ( x y quot1 quot2 -- z )
    #! quot1 ( x y -- z/f ) finds an existing z
    #! quot2 ( x y -- z ) creates a new z if quot1 returns f
    >r >r 2dup r> call [ 2nip ] r> if* ;

: create-context ( context-name -- context-id ) create-node ;

! relations:
!  - have a context in context 'semantic-db'

: create-relation ( relation-name context-id -- relation-id )
    [ create-node dup ] dip has-context-relation create-arc drop ;

: get-relation ( relation-name context-id -- relation-id/f )
    [
        ":context" INTEGER param ,
        ":name" TEXT param ,
        has-context-relation ":has_context" INTEGER param ,
    ] { } make
    "select n.id from node n, arc a where n.content = :name and n.id = a.subject and a.relation = :has_context and a.object = :context"
    single-int-results ?first ;

: relation-id ( relation-name context-id -- relation-id )
    [ get-relation ] [ create-relation ] ensure2 ;

! hierarchy
TUPLE: tree id children ;
C: <tree> tree

: parent-child ( parent child has-parent-relation -- arc-id ) swapd create-arc ;

: un-parent-child ( parent child has-parent-relation -- )
    swapd <arc> select-tuples [ id>> delete-arc ] each ;

: child-arcs ( parent-id has-parent-relation -- child-arcs )
    f -rot <arc> select-tuples ;

: children ( node-id has-parent-relation -- children )
    child-arcs [ subject>> ] map ;

: parent-arcs ( node-id has-parent-relation -- parent-arcs )
    f swap <arc> select-tuples ;

: parents ( node-id has-parent-relation -- parents )
     parent-arcs [ object>> ] map ;

: get-node-hierarchy ( node-id has-parent-relation -- tree )
    2dup children >r [ get-node-hierarchy ] curry r> swap map <tree> ;

: (get-root-nodes) ( node-id has-parent-relation -- root-nodes/node-id )
    2dup parents dup empty? [
        2drop
    ] [
        >r nip [ (get-root-nodes) ] curry r> swap map
    ] if ;

: get-root-nodes ( node-id has-parent-relation -- root-nodes )
    (get-root-nodes) flatten prune ;

! sets

: in-set* ( set member in-set-relation -- arc-id ) swapd create-arc ;

: in-set? ( set member in-set-relation -- ? )
    swapd <arc> select-tuples length 0 > ;

: set-members ( set in-set-relation -- members )
    f -rot <arc> select-tuples [ id>> ] map ;
