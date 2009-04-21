! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors db2 db2.statements.tests db2.tester
kernel tools.test db2.fql ;
IN: db2.fql.tests

: test-fql ( -- )
    create-computer-table

    [ "insert into computer (name, os) values (?, ?);" ]
    [
        "computer" { "name" "os" } { "lol" "os2" } <insert> expand-fql
        sql>>
    ] unit-test

    [ "select name, os from computer" ]
    [
        select new
            { "name" "os" } >>names
            "computer" >>from
        expand-fql sql>>
    ] unit-test
    
    [ "select name, os from computer group by os order by lol offset 100 limit 3" ]
    [
        select new
            { "name" "os" } >>names
            "computer" >>from
            "os" >>group-by
            "lol" >>order-by
            100 >>offset
            3 >>limit
        expand-fql sql>>
    ] unit-test

    [
        "select name, os from computer where (hmm > 1 or foo is NULL) group by os order by lol offset 100 limit 3"
    ] [
        select new
            { "name" "os" } >>names
            "computer" >>from
            T{ or f { "hmm > 1" "foo is NULL" } } >>where
            "os" >>group-by
            "lol" >>order-by
            100 >>offset
            3 >>limit
        expand-fql sql>>
    ] unit-test

    [ "delete from computer order by omg limit 3" ]
    [
        delete new
            "computer" >>tables
            "omg" >>order-by
            3 >>limit
        expand-fql sql>>
    ] unit-test

    [ "update computer set name = oscar order by omg limit 3" ]
    [
        update new
            "computer" >>tables
            "name" >>keys
            "oscar" >>values
            "omg" >>order-by
            3 >>limit
        expand-fql sql>>
    ] unit-test

    ;

[ test-fql ] test-dbs
