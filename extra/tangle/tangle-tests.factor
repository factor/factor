USING: accessors arrays continuations db db.sqlite io.files kernel semantic-db sequences tangle tangle.html tangle.menu tangle.page tangle.path tools.test tools.walker tuple-syntax ;
IN: tangle.tests

: db-path "tangle-test.db" temp-file ;
: test-db db-path sqlite-db ;
: delete-db [ db-path delete-file ] ignore-errors ;

: test-tangle ( -- )
    ensure-root "foo" create-file "bar" create-file "pluck_eggs" create-file
    "How to Pluck Eggs" create-node swap has-filename
    "Main Menu" ensure-menu "home" create-node swap subitem-of ;

test-db [
    init-semantic-db test-tangle
    [ "pluck_eggs" ] [ { "foo" "bar" "pluck_eggs" } path>node [ node-content ] when* ] unit-test
    [ "How to Pluck Eggs" ] [ { "foo" "bar" "pluck_eggs" } path>node [ has-filename-subjects first node-content ] when* ] unit-test
    [ { "foo" "bar" "pluck_eggs" } ] [ { "foo" "bar" "pluck_eggs" } path>node node>path >array ] unit-test
    [ f ] [ TUPLE{ node id: 666 content: "some content" } parent-directory ] unit-test
    [ f ] [ TUPLE{ node id: 666 content: "some content" } node>path ] unit-test
    [ "Main Menu" ] [ "Main Menu" ensure-menu node-content ] unit-test
    [ t ] [ "Main Menu" ensure-menu "Main Menu" ensure-menu node= ] unit-test
    [ "Main Menu" { "home" } ] [ "Main Menu" load-menu dup node>> node-content swap children>> [ node>> node-content ] map >array ] unit-test
    [ { "home" } ] [ "Main Menu" load-menu menu>ulist items>> [ node>> node-content ] map >array ] unit-test
    [ f ] [ TUPLE{ node id: 666 content: "node text" } node>path ] unit-test
    [ "node text" ] [ TUPLE{ node id: 666 content: "node text" } >html ] unit-test
] with-db delete-db
