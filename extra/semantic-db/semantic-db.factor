! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays db db.tuples db.types db.sqlite kernel new-slots sequences ;
IN: semantic-db

! new semantic-db using Doug Coleman's new db abstraction library

TUPLE: node id content ;
: <node> ( content -- node )
    node construct-empty swap >>content ;

node "node"
{
    { "id" "id" SERIAL +native-id+ +autoincrement+ }
    { "content" "content" TEXT }
} define-persistent

: create-node-table ( -- )
    node create-table ;

: create-node ( content -- id )
    <node> dup persist id>> ;

TUPLE: arc relation subject object ;

: <arc> ( relation subject object -- arc )
    arc construct-empty
    f <node> over set-delegate
    swap >>object swap >>subject swap >>relation ;

arc "arc"
{
    { "id" "id" SERIAL +native-id+ } ! foreign key to node table?
    { "relation" "relation" SERIAL +not-null+ }
    { "subject" "subject" SERIAL +not-null+ }
    { "object" "object" SERIAL +not-null+ }
} define-persistent

: create-arc-table ( -- )
    arc create-table ;

: insert-arc ( arc -- )
    dup delegate insert-tuple
    [ ] [ insert-sql ] make-tuple-statement insert-statement drop ;

: persist-arc ( arc -- )
    dup primary-key [ update-tuple ] [ insert-arc ] if ;

: delete-arc ( arc -- )
    dup delete-tuple delegate delete-tuple ;

: create-arc ( relation subject object -- id )
    <arc> dup persist-arc id>> ;

: create-bootstrap-nodes ( -- )
    { "context" "relation" "is of type" "semantic-db" "is in context" }
    [ create-node drop ] each ;

: context-type 1 ; inline
: relation-type 2 ; inline
: has-type-relation 3 ; inline
: semantic-db-context 4 ; inline
: has-context-relation 5 ; inline

: create-bootstrap-arcs ( -- )
    has-type-relation has-type-relation relation-type create-arc drop
    has-type-relation semantic-db-context context-type create-arc drop
    has-context-relation has-type-relation semantic-db-context create-arc drop
    has-type-relation has-context-relation relation-type create-arc drop
    has-context-relation has-context-relation semantic-db-context create-arc drop ;

: init-semantic-db ( -- )
    create-node-table create-arc-table create-bootstrap-nodes create-bootstrap-arcs ;

