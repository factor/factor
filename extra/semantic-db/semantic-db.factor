! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays continuations db db.tuples db.types db.sqlite kernel math math.parser new-slots sequences ;
IN: semantic-db

TUPLE: node id content ;
: <node> ( content -- node )
    node construct-empty swap >>content ;

node "node"
{
    { "id" "id" +native-id+ +autoincrement+ }
    { "content" "content" TEXT }
} define-persistent

: create-node-table ( -- )
    node create-table ;

: create-node ( content -- id )
    <node> dup insert-tuple id>> ;

TUPLE: arc id relation subject object ;

: <arc> ( relation subject object -- arc )
    arc construct-empty swap >>object swap >>subject swap >>relation ;

arc "arc"
{
    { "id" "id" INTEGER +assigned-id+ } ! foreign key to node table?
    { "relation" "relation" INTEGER +not-null+ }
    { "subject" "subject" INTEGER +not-null+ }
    { "object" "object" INTEGER +not-null+ }
} define-persistent

: create-arc-table ( -- )
    arc create-table ;

: insert-arc ( arc -- )
    f <node> dup insert-tuple id>> >>id insert-tuple ;

: delete-arc ( arc -- )
    dup delete-tuple delegate delete-tuple ;

: create-arc ( relation subject object -- id )
    <arc> dup insert-arc id>> ;

: create-bootstrap-nodes ( -- )
    { "context" "type" "relation" "has type" "semantic-db" "has context" }
    [ create-node drop ] each ;

! TODO: maybe put these in a 'special nodes' table
: context-type 1 ; inline
: type-type 2 ; inline
: relation-type 3 ; inline
: has-type-relation 4 ; inline
: semantic-db-context 5 ; inline
: has-context-relation 6 ; inline

: has-semantic-db-context ( id -- )
    has-context-relation swap semantic-db-context create-arc drop ;

: has-type-in-semantic-db ( subject type -- )
    has-type-relation -rot create-arc drop ;

: create-bootstrap-arcs ( -- )
    ! give everything a type
    context-type type-type has-type-in-semantic-db
    type-type type-type has-type-in-semantic-db
    relation-type type-type has-type-in-semantic-db
    has-type-relation relation-type has-type-in-semantic-db
    semantic-db-context context-type has-type-in-semantic-db
    has-context-relation relation-type has-type-in-semantic-db
    ! give relations and types the semantic-db context
    context-type has-semantic-db-context
    type-type has-semantic-db-context
    relation-type has-semantic-db-context
    has-type-relation has-semantic-db-context
    has-context-relation has-semantic-db-context ;

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
