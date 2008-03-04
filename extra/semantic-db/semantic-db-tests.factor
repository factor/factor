USING: accessors db db.sqlite db.tuples kernel math semantic-db semantic-db.type tools.test ;
IN: temporary

[
USE: tools.walker
break
    create-node-table create-arc-table
    [ 1 ] [ "first node" create-node ] unit-test
    [ 2 ] [ "second node" create-node ] unit-test
    [ 3 ] [ "third node" create-node ] unit-test
    [ 4 ] [ f create-node ] unit-test
    [ 5 ] [ 1 2 3 create-arc ] unit-test
] with-tmp-sqlite

[
    init-semantic-db
    [ t ] [ "content" ensure-type "this is some content" ensure-node-of-type integer? ] unit-test
    [ t ] [ "content" select-node-of-type integer? ]
] with-tmp-sqlite
