! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors db2 db2.fql db2.statements.tests db2.tester
kernel tools.test ;
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

    ;

[ test-fql ] test-dbs
