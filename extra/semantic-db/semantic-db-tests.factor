USING: accessors arrays continuations db db.sqlite db.tuples io.files
kernel math namespaces semantic-db

sequences sorting tools.test tools.walker ;
IN: semantic-db.tests

SYMBOL: context
SYMBOL: has-parent-relation

: db-path "semantic-db-test.db" temp-file ;
: test-db db-path sqlite-db ;
: delete-db [ db-path delete-file ] ignore-errors ;

delete-db

test-db [
    node create-table arc create-table
    [ 1 ] [ "first node" create-node ] unit-test
    [ 2 ] [ "second node" create-node ] unit-test
    [ 3 ] [ "third node" create-node ] unit-test
    [ 4 ] [ f create-node ] unit-test
    [ 5 ] [ 1 2 3 create-arc ] unit-test
] with-db delete-db

test-db [
    init-semantic-db
    "test content" create-context context set
    [ 4 ] [ context get ] unit-test
    [ 5 ] [ "is test content" context get create-relation ] unit-test
    [ 5 ] [ "is test content" context get get-relation ] unit-test
    [ 5 ] [ "is test content" context get relation-id ] unit-test
    [ 7 ] [ "has parent" context get relation-id ] unit-test
    [ 7 ] [ "has parent" context get relation-id ] unit-test
    [ "has parent" ] [ "has parent" context get relation-id node-content ] unit-test
    [ "test content" ] [ context get node-content ] unit-test
] with-db delete-db

! test hierarchy
test-db [
    init-semantic-db
    "family tree" create-context context set
    "has parent" context get relation-id has-parent-relation set
    "adam" create-node "adam" set
    "eve" create-node "eve" set
    "bob" create-node "bob" set
    "fran" create-node "fran" set
    "charlie" create-node "charlie" set
    "gertrude" create-node "gertrude" set
     [ t ] [ "adam" get "bob" get has-parent-relation get parent-child integer? ] unit-test
    { { "eve" "bob" } { "eve" "fran" } { "bob" "gertrude" } { "bob" "fran" } { "fran" "charlie" } } [ first2 [ get ] 2apply has-parent-relation get parent-child drop ] each
    [ { "bob" "fran" } ] [ "eve" get has-parent-relation get children [ node-content ] map ] unit-test
    [ { "adam" "eve" } ] [ "bob" get has-parent-relation get parents [ node-content ] map ] unit-test
    [ "fran" { "charlie" } ] [ "fran" get has-parent-relation get get-node-hierarchy dup tree-id node-content swap tree-children [ tree-id node-content ] map ] unit-test
    [ { "adam" "eve" } ] [ "charlie" get has-parent-relation get get-root-nodes [ node-content ] map natural-sort >array ] unit-test
    [ { } ] [ "fran" get "charlie" get tuck has-parent-relation get un-parent-child has-parent-relation get parents [ node-content ] map ] unit-test
] with-db delete-db

RELATION: test-relation

test-db [
    init-semantic-db
    [ 5 ] [ test-relation ] unit-test
] with-db delete-db

