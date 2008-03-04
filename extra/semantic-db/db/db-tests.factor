USING: io.files kernel namespaces semantic-db.db semantic-db.db.private sqlite tools.test ;
IN: temporary

[ "n.id" ] [ "id" "n" [ 0 column-text ] <field> field-sql ] unit-test
[ "select n.id from nodes n where n.content = :content" ] [
    <query>
    "id" "n" [ 0 column-text ] <field> over add-field 
    "nodes n" over add-table
    "n.content = :content" over add-condition
    query-sql
] unit-test

[
    create-node-table create-arc-table 
    [ 1 ] [ "first node" create-node ] unit-test
    [ 2 ] [ "second node" create-node ] unit-test
    [ 3 ] [ "third node" create-node ] unit-test
    [ 4 ] [ f create-node ] unit-test
    [ "first node" ] [ 1 node-content ] unit-test
    [ 5 ] [ 1 2 3 create-arc ] unit-test
    [ { { 1 2 3 } } ] [ 2 node-arcs ] unit-test
    [ { { 1 2 3 } } ] [ 3 node-arcs ] unit-test
    [ { { 3 1 } } ] [ 2 node-subject-arcs ] unit-test
    [ { { 2 1 } } ] [ 3 node-object-arcs ] unit-test
]
with-tmp-db
