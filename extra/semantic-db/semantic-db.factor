! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators.cleave continuations db db.tuples db.types db.sqlite hashtables kernel math math.parser namespaces new-slots parser sequences sequences.deep sequences.lib words ;
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

: has-arc? ( subject object relation -- ? )
    <arc> select-tuples length 0 > ;

: select-arcs ( subject object relation -- arcs )
    <arc> select-tuples ;

: select-arc-ids ( subject object relation -- arc-ids )
    select-arcs [ id>> ] map ;

: select-arc-subjects ( subject object relation -- subject-ids )
    select-arcs [ subject>> ] map ;

: select-arc-objects ( subject object relation -- object-ids )
    select-arcs [ object>> ] map ;

: delete-arcs ( subject object relation -- )
    select-arcs [ id>> delete-arc ] each ;

: subject-relation ( subject relation -- subject object relation )
    f swap ;

: object-relation ( object relation -- subject object relation )
    f -rot ;

arc "arc"
{
    { "id" "id" INTEGER +assigned-id+ } ! foreign key to node table?
    { "relation" "relation" INTEGER +not-null+ }
    { "subject" "subject" INTEGER +not-null+ }
    { "object" "object" INTEGER +not-null+ }
} define-persistent

: create-bootstrap-nodes ( -- )
    "semantic-db" create-node drop
    "has-context" create-node drop ;

: semantic-db-context  1 ;
: has-context-relation 2 ;

: create-bootstrap-arcs ( -- )
    has-context-relation semantic-db-context has-context-relation create-arc drop ;

: init-semantic-db ( -- )
    node create-table
    arc create-table
    create-bootstrap-nodes create-bootstrap-arcs ;

: param ( value key type -- param )
    swapd 3array ;

: single-int-results ( bindings sql -- array )
    f f <simple-statement> [ do-bound-query ] with-disposal
    [ first string>number ] map ;

: ensure1 ( x quot1 quot2 -- y )
    #! quot1 ( x -- y/f ) tries to find an existing y
    #! quot2 ( x -- y ) creates a new y if quot1 returns f
    >r dupd call [ nip ] r> if* ;

: ensure2 ( x y quot1 quot2 -- z )
    #! quot1 ( x y -- z/f ) tries to find an existing z
    #! quot2 ( x y -- z ) creates a new z if quot1 returns f
    >r >r 2dup r> call [ 2nip ] r> if* ;

! contexts:
!  - a node n is a context iff there exists a relation r such that r has context n
: create-context ( context-name -- context-id ) create-node ;

: get-context ( context-name -- context-id/f )
    [
        ":name" TEXT param ,
        has-context-relation ":has_context" INTEGER param ,
    ] { } make
    "select distinct n.id from node n, arc a where n.content = :name and a.relation = :has_context and a.object = n.id"
    single-int-results ?first ;

: context-id ( context-name -- context-id )
    [ get-context ] [ create-context ] ensure1 ;

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

! RELATION: is-fooey
!  - define a word is-fooey in the current vocab (foo), that when called:
!    - finds or creates a node called "is-fooey" with context "foo", and returns its id
: RELATION:
    CREATE-WORD dup [ word-name ] [ word-vocabulary ] bi
    [ context-id relation-id ] 2curry define ; parsing

! hierarchy
TUPLE: tree id children ;
C: <tree> tree

: parent-child ( parent child has-parent-relation -- arc-id )
    swapd create-arc ;

: un-parent-child ( parent child has-parent-relation -- )
    swapd delete-arcs ;

: children ( node-id has-parent-relation -- children )
    object-relation select-arc-subjects ;

: parents ( node-id has-parent-relation -- parents )
    subject-relation select-arc-objects ;

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
: in-set ( member set in-set-relation -- arc-id ) create-arc ;
: in-set? ( member set in-set-relation -- ? ) has-arc? ;
: set-members ( set in-set-relation -- members )
    object-relation select-arc-subjects ;

! attributes
: has-attribute ( node value has-attribute-relation -- arc-id ) create-arc ;
: has-attribute? ( node value has-attribute-relation -- ? ) has-arc? ;
: nodes-with-attribute ( value has-attribute-relation -- node-ids )
    object-relation select-arc-subjects ;
