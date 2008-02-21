USING: accessors db db.sqlite db.tuples kernel semantic-db tools.test ;
IN: temporary

[
    create-node-table create-arc-table
    [ 1 ] [ "first node" create-node ] unit-test
    [ 2 ] [ "second node" create-node ] unit-test
    [ 3 ] [ "third node" create-node ] unit-test
    [ 4 ] [ f create-node ] unit-test
    [ 5 ] [ 1 2 3 create-arc ] unit-test
] with-tmp-sqlite
