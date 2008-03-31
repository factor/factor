USING: accessors arrays continuations db db.sqlite
db.tuples io.files kernel math namespaces semantic-db
semantic-db.context semantic-db.hierarchy
semantic-db.relations sequences sorting tools.test
tools.walker ;
IN: semantic-db.tests

: db-path "semantic-db-test.db" temp-file ;
: test-db db-path sqlite-db ;
: delete-db [ db-path delete-file ] ignore-errors ;

delete-db

test-db [
    create-node-table create-arc-table
    [ 1 ] [ "first node" create-node* ] unit-test
    [ 2 ] [ "second node" create-node* ] unit-test
    [ 3 ] [ "third node" create-node* ] unit-test
    [ 4 ] [ f create-node* ] unit-test
    [ 5 ] [ 1 2 3 create-arc* ] unit-test
] with-db

delete-db

test-db [
    init-semantic-db
    "test content" create-context* [
        [ 4 ] [ context ] unit-test
        [ 5 ] [ context "is test content" create-relation* ] unit-test
        [ 5 ] [ context "is test content" get-relation ] unit-test
        [ 5 ] [ "is test content" relation-id ] unit-test
        [ 7 ] [ "has parent" relation-id ] unit-test
        [ 7 ] [ "has parent" relation-id ] unit-test
        [ "has parent" ] [ "has parent" relation-id node-content ] unit-test
        [ "test content" ] [ context node-content ] unit-test
    ] with-context
    ! type-type 1array [ "type" ensure-type ] unit-test
    ! [ { 1 2 3 } ] [ type-type select-nodes-of-type ] unit-test
    ! [ 1 ] [ type-type select-node-of-type ] unit-test
    ! [ t ] [ "content" ensure-type integer? ] unit-test
    ! [ t ] [ "content" ensure-type "content" ensure-type = ] unit-test
    ! [ t ] [ "content" ensure-type "first content" create-node-of-type integer? ] unit-test
    ! [ t ] [ "content" ensure-type select-node-of-type integer? ] unit-test
    ! [ t ] [ "content" ensure-type "first content" select-node-of-type-with-content integer? ] unit-test
    ! [ t ] [ "content" ensure-type "first content" ensure-node-of-type integer? ] unit-test
    ! [ t ] [ "content" ensure-type "second content" ensure-node-of-type integer? ] unit-test
    ! [ 2 ] [ "content" ensure-type select-nodes-of-type length ] unit-test
] with-db

delete-db

! test hierarchy
test-db [
    init-semantic-db
    "family tree" create-context* [
        "adam" create-node* "adam" set
        "eve" create-node* "eve" set
        "bob" create-node* "bob" set
        "fran" create-node* "fran" set
        "charlie" create-node* "charlie" set
        "gertrude" create-node* "gertrude" set
        [ t ] [ "adam" get "bob" get parent-child* integer? ] unit-test
        { { "eve" "bob" } { "eve" "fran" } { "bob" "gertrude" } { "bob" "fran" } { "fran" "charlie" } } [ first2 [ get ] bi@ parent-child ] each
        [ { "bob" "fran" } ] [ "eve" get children [ node-content ] map ] unit-test
        [ { "adam" "eve" } ] [ "bob" get parents [ node-content ] map ] unit-test
        [ "fran" { "charlie" } ] [ "fran" get get-node-hierarchy dup tree-id node-content swap tree-children [ tree-id node-content ] map ] unit-test
        [ { "adam" "eve" } ] [ "charlie" get get-root-nodes [ node-content ] map natural-sort >array ] unit-test
        [ { } ] [ "fran" get "charlie" get tuck un-parent-child parents [ node-content ] map ] unit-test
    ] with-context
] with-db

delete-db
