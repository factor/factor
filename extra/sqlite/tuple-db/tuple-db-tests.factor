! Copyright (C) 2005 Chris Double.
! See http://factorcode.org/license.txt for BSD license.

IN: temporary
USING: io io.files kernel sequences namespaces
hashtables sqlite sqlite.tuple-db math words tools.test ;

TUPLE: testdata one two ;

C: <testdata> testdata

testdata default-mapping set-mapping

"libs/sqlite/test.db" resource-path [

    db get testdata create-tuple-table

    [ "two" { } ] [
    db get "one" "two" <testdata> insert-tuple
    db get "one" f <testdata> find-tuples 
    first [ testdata-two ] keep
    db get swap delete-tuple    
    db get "one" f <testdata> find-tuples 
    ] unit-test

    [ "junk" ] [
    db get "one" "two" <testdata> insert-tuple
    db get "one" f <testdata> find-tuples 
    first  
    "junk" over set-testdata-two
    db get swap update-tuple
    db get "one" f <testdata> find-tuples 
    first [ testdata-two ] keep
    db get swap delete-tuple      
    ] unit-test

    db get testdata drop-tuple-table
] with-sqlite

