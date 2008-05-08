USING: accessors arrays continuations db db.sqlite db.tuples io.files
kernel math namespaces semantic-db sequences sorting tools.test
tools.walker ;
IN: semantic-db.tests

SYMBOL: context

: db-path "semantic-db-test.db" temp-file ;
: test-db db-path sqlite-db ;
: delete-db [ db-path delete-file ] ignore-errors ;

delete-db

test-db [
    node create-table arc create-table
    [ 1 ] [ "first node" create-node id>> ] unit-test
    [ 2 ] [ "second node" create-node id>> ] unit-test
    [ 3 ] [ "third node" create-node id>> ] unit-test
    [ 4 ] [ f create-node id>> ] unit-test
    [ ] [ 1 f <node> 2 f <node> 3 f <node> create-arc ] unit-test
    [ { 1 2 3 4 } ] [ all-node-ids ] unit-test
] with-db delete-db

 test-db [
     init-semantic-db
     "test content" create-context context set
     [ T{ node f 3 "test content" } ] [ context get ] unit-test
     [ T{ node f 4 "is test content" } ] [ "is test content" context get create-relation ] unit-test
     [ T{ node f 4 "is test content" } ] [ "is test content" context get get-relation ] unit-test
     [ T{ node f 4 "is test content" } ] [ "is test content" context get ensure-relation ] unit-test
     [ T{ node f 5 "has parent" } ] [ "has parent" context get ensure-relation ] unit-test
     [ T{ node f 5 "has parent" } ] [ "has parent" context get ensure-relation ] unit-test
     [ "has parent" ] [ "has parent" context get ensure-relation node-content ] unit-test
     [ "test content" ] [ context get node-content ] unit-test
 ] with-db delete-db
 
 ! "test1" "test1-relation-id-word" f f f f <relation-definition> define-relation
 ! "test2" t t t t t <relation-definition> define-relation
 RELATION: test3
 test-db [
     init-semantic-db
     ! [ T{ node f 3 "test1" } ] [ test1-relation-id-word ] unit-test
     ! [ T{ node f 4 "test2" } ] [ test2-relation ] unit-test
     [ T{ node f 4 "test3" } ] [ test3-relation ] unit-test
 ] with-db delete-db
 
 ! test hierarchy
 RELATION: has-parent
 test-db [
     init-semantic-db
     "adam" create-node "adam" set
     "eve" create-node "eve" set
     "bob" create-node "bob" set
     "fran" create-node "fran" set
     "charlie" create-node "charlie" set
     "gertrude" create-node "gertrude" set
      [ ] [ "bob" get "adam" get has-parent ] unit-test
     { { "bob" "eve" } { "fran" "eve" } { "gertrude" "bob" } { "fran" "bob" } { "charlie" "fran" } } [ first2 [ get ] bi@ has-parent ] each
     [ { "bob" "fran" } ] [ "eve" get has-parent-relation children [ node-content ] map ] unit-test
     [ { "adam" "eve" } ] [ "bob" get has-parent-relation parents [ node-content ] map ] unit-test
     [ "fran" { "charlie" } ] [ "fran" get has-parent-relation get-node-tree-s dup node>> node-content swap children>> [ node>> node-content ] map ] unit-test
     [ { "adam" "eve" } ] [ "charlie" get has-parent-relation get-root-nodes [ node-content ] map natural-sort >array ] unit-test
     [ { } ] [ "charlie" get dup "fran" get !has-parent has-parent-relation parents [ node-content ] map ] unit-test
     [ { "adam" "eve" } ] [ has-parent-relation ultimate-objects node-results [ node-content ] map ] unit-test
     [ { "fran" "gertrude" } ] [ has-parent-relation ultimate-subjects node-results [ node-content ] map ] unit-test
 ] with-db delete-db
 
