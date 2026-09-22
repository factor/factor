USING: accessors db db.sqlite db.tuples db.types kernel tools.test ;
IN: db.types.tests

! #2656: +primary-key+ is a union, not a concrete assignment policy.
[ f { "key" "KEY" TEXT +primary-key+ } spec>tuple ] [ primary-key-policy-required? ] must-fail-with
[ f { "key" "KEY" +primary-key+ } spec>tuple ] [ primary-key-policy-required? ] must-fail-with

{ +user-assigned-id+ } [
    f { "key" "KEY" TEXT +user-assigned-id+ } spec>tuple primary-key>>
] unit-test
{ +db-assigned-id+ } [
    f { "key" "KEY" +db-assigned-id+ } spec>tuple primary-key>>
] unit-test
{ f } [ f { "value" "VALUE" TEXT } spec>tuple primary-key>> ] unit-test

TUPLE: primary-key-test key value ;
[ primary-key-test "KEY_TEST" {
    { "key" "KEY" TEXT +primary-key+ }
    { "value" "VALUE" TEXT }
} define-persistent ] [ primary-key-policy-required? ] must-fail-with

primary-key-test "KEY_TEST" {
    { "key" "KEY" TEXT +user-assigned-id+ }
    { "value" "VALUE" TEXT }
} define-persistent

{ "Earth" } [
    [ "keys.db" <sqlite-db> [
        primary-key-test create-table
        "Hello" "World" primary-key-test boa insert-tuple
        "Hello" "Earth" primary-key-test boa update-tuple
        "Hello" f primary-key-test boa select-tuple value>>
    ] with-db ] with-test-directory
] unit-test
