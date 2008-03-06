USING: accessors arrays db db.sqlite db.tuples kernel math semantic-db semantic-db.type sequences tools.test tools.walker ;
IN: temporary

[
    create-node-table create-arc-table
    [ 1 ] [ "first node" create-node ] unit-test
    [ 2 ] [ "second node" create-node ] unit-test
    [ 3 ] [ "third node" create-node ] unit-test
    [ 4 ] [ f create-node ] unit-test
    [ 5 ] [ 1 2 3 create-arc ] unit-test
] with-tmp-sqlite

[
    init-semantic-db
    type-type 1array [ "type" ensure-type ] unit-test
    [ { 1 2 3 } ] [ type-type select-nodes-of-type ] unit-test
    [ 1 ] [ type-type select-node-of-type ] unit-test
    [ t ] [ "content" ensure-type integer? ] unit-test
    [ t ] [ "content" ensure-type "content" ensure-type = ] unit-test
    [ t ] [ "content" ensure-type "first content" create-node-of-type integer? ] unit-test
    [ t ] [ "content" ensure-type select-node-of-type integer? ] unit-test
    [ t ] [ "content" ensure-type "first content" select-node-of-type-with-content integer? ] unit-test
    [ t ] [ "content" ensure-type "first content" ensure-node-of-type integer? ] unit-test
    [ t ] [ "content" ensure-type "second content" ensure-node-of-type integer? ] unit-test
    [ 2 ] [ "content" ensure-type select-nodes-of-type length ] unit-test
] with-tmp-sqlite
