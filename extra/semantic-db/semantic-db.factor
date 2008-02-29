! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays db db.tuples db.types db.sqlite kernel math new-slots sequences ;
IN: semantic-db

! new semantic-db using Doug Coleman's new db abstraction library

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

TUPLE: arc relation subject object ;

: <arc> ( relation subject object -- arc )
    arc construct-empty
    f <node> over set-delegate
    swap >>object swap >>subject swap >>relation ;

arc "arc"
{
    { "id" "id" INTEGER } ! foreign key to node table?
    { "relation" "relation" INTEGER +not-null+ }
    { "subject" "subject" INTEGER +not-null+ }
    { "object" "object" INTEGER +not-null+ }
} define-persistent

: create-arc-table ( -- )
    arc create-table ;

: insert-arc ( arc -- )
    dup delegate insert-tuple
    insert-tuple ;
   ! [ ] [ insert-sql ] make-tuple-statement insert-statement drop ;

! : insert-arc ( arc -- )
!     dup primary-key [ update-tuple ] [ insert-arc ] if ;

: delete-arc ( arc -- )
    dup delete-tuple delegate delete-tuple ;

: create-arc ( relation subject object -- id )
    <arc> dup insert-arc id>> ;

: create-bootstrap-nodes ( -- )
    { "context" "type" "relation" "is of type" "semantic-db" "is in context" }
    [ create-node drop ] each ;

! TODO: maybe put these in a 'special nodes' table
: context-type 1 ; inline
: type-type 2 ; inline
: relation-type 3 ; inline
: has-type-relation 4 ; inline
: semantic-db-context 5 ; inline
: has-context-relation 6 ; inline

: create-bootstrap-arcs ( -- )
    ! give everything a type
    has-type-relation context-type type-type create-arc drop
    has-type-relation type-type type-type create-arc drop
    has-type-relation relation-type type-type create-arc drop
    has-type-relation has-type-relation relation-type create-arc drop
    has-type-relation semantic-db-context context-type create-arc drop
    has-type-relation has-context-relation relation-type create-arc drop
    ! give relations a context (semantic-db context)
    has-context-relation has-type-relation semantic-db-context create-arc drop
    has-context-relation has-context-relation semantic-db-context create-arc drop ;

: init-semantic-db ( -- )
    create-node-table create-arc-table create-bootstrap-nodes create-bootstrap-arcs ;

: 1result ( array -- result )
    #! return the first (and hopefully only) element of the array, or f
    dup length zero? [ drop f ] [ first ] if ;

: param ( value key type -- param )
    rot 3array ;
