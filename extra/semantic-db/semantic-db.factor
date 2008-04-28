! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays continuations db db.tuples db.types db.sqlite kernel math math.parser sequences ;
IN: semantic-db

TUPLE: node id content ;
: <node> ( content -- node )
    node new swap >>content ;

: <id-node> ( id -- node )
    node new swap >>id ;

node "node"
{
    { "id" "id" +db-assigned-id+ +autoincrement+ }
    { "content" "content" TEXT }
} define-persistent

: create-node-table ( -- )
    node create-table ;

: delete-node ( node-id -- )
    <id-node> delete-tuple ;

: create-node* ( str -- node-id )
    <node> dup insert-tuple id>> ;

: create-node ( str -- )
    create-node* drop ;

: node-content ( id -- str )
    f <node> swap >>id select-tuple content>> ;

TUPLE: arc id relation subject object ;

: <arc> ( relation subject object -- arc )
    arc new swap >>object swap >>subject swap >>relation ;

: <id-arc> ( id -- arc )
    arc new swap >>id ;

: insert-arc ( arc -- )
    f <node> dup insert-tuple id>> >>id insert-tuple ;

: delete-arc ( arc-id -- )
    dup delete-node <id-arc> delete-tuple ;

: create-arc* ( relation subject object -- arc-id )
    <arc> dup insert-arc id>> ;

: create-arc ( relation subject object -- )
    create-arc* drop ;

arc "arc"
{
    { "id" "id" INTEGER +assigned-id+ } ! foreign key to node table?
    { "relation" "relation" INTEGER +not-null+ }
    { "subject" "subject" INTEGER +not-null+ }
    { "object" "object" INTEGER +not-null+ }
} define-persistent

: create-arc-table ( -- )
    arc create-table ;

: create-bootstrap-nodes ( -- )
    "semantic-db" create-node
    "has context" create-node ;

: semantic-db-context 1 ;
: has-context-relation 2 ;

: create-bootstrap-arcs ( -- )
    has-context-relation has-context-relation semantic-db-context create-arc ;    

: init-semantic-db ( -- )
    create-node-table create-arc-table create-bootstrap-nodes create-bootstrap-arcs ;

: param ( value key type -- param )
    swapd <sqlite-low-level-binding> ;

: single-int-results ( bindings sql -- array )
    f f <simple-statement> [ do-bound-query ] with-disposal
    [ first string>number ] map ;

: ensure2 ( x y quot1 quot2 -- z )
    #! quot1 ( x y -- z/f ) finds an existing z
    #! quot2 ( x y -- z ) creates a new z if quot1 returns f
    >r >r 2dup r> call [ 2nip ] r> if* ;

