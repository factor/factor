! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: db2 db2.debug db2.types debugger
kernel orm.persistent orm.tuples sequences
tools.test ;
IN: orm.tuples.tests

TUPLE: foo-1 a b ;

PERSISTENT: foo-1
{ "a" INTEGER +primary-key+ }
{ "b" VARCHAR } ;

: test-1 ( -- )
    [ "drop table foo_1" sql-command ] try

    [ ]
    [ "create table foo_1 (a integer primary key, b varchar)" sql-command ] unit-test

    [ ]
    [ 1 "lol" foo-1 boa insert-tuple ] unit-test

    [ { { "1" "lol" } } ]
    [ "select * from foo_1" sql-query ] unit-test

    [ ]
    [ 1 "omg" foo-1 boa update-tuple ] unit-test

    [ { { "1" "omg" } } ]
    [ "select * from foo_1" sql-query ] unit-test

    [ { { "1" "omg" } } ]
    [ "select * from foo_1" sql-query ] unit-test

    [ { T{ foo-1 { a 1 } { b "omg" } } } ]
    [ T{ foo-1 } select-tuples ] unit-test

    [ ] [ 1 f foo-1 boa delete-tuples ] unit-test

    [ { } ] [ "select * from foo_1" sql-query ] unit-test
    [ { } ] [ T{ foo-1 } select-tuples ] unit-test

    [ ] [ 1 "lol" foo-1 boa insert-tuple ] unit-test

    [ { T{ foo-1 { a 1 } { b "lol" } } } ]
    [ T{ foo-1 f 1 } select-tuples ] unit-test

    [ { T{ foo-1 { a 1 } { b "lol" } } } ]
    [ T{ foo-1 f f "lol" } select-tuples ] unit-test

    [ { T{ foo-1 { a 1 } { b "lol" } } } ]
    [ T{ foo-1 f 1 "lol" } select-tuples ] unit-test
    ;

[ test-1 ] test-dbs

TUPLE: foo-2 id a ;
PERSISTENT: foo-2
{ "id" INTEGER +primary-key+ }
{ "a" VARCHAR } ;

TUPLE: bar-2 id b ;
PERSISTENT: bar-2
{ "id" INTEGER +primary-key+ }
{ "b" { foo-2 sequence } } ;

: setup-test-2-sql ( -- )
    [ "drop table foo_2" sql-command ] try
    [ "drop table bar_2" sql-command ] try

    [ ] [ "create table foo_2(id integer primary key, a varchar, bar_2_id integer)" sql-command ] unit-test
    [ ] [ "create table bar_2(id integer primary key)" sql-command ] unit-test

    [ ] [ "insert into foo_2(id, a, bar_2_id) values(0, 'first', 0);" sql-command ] unit-test
    [ ] [ "insert into foo_2(id, a, bar_2_id) values(1, 'second', 0);" sql-command ] unit-test

    [ ] [ "insert into bar_2(id) values(0);" sql-command ] unit-test

    [
        {
            { "0" "0" "first" }
            { "0" "1" "second" }
        }
    ] [ "select bar_2.id, foo_2.id, foo_2.a from bar_2 left join foo_2 on foo_2.bar_2_id = bar_2.id where bar_2.id = 0" sql-query ] unit-test

    ;

: test-2 ( -- )
    setup-test-2-sql

    ! [ ] [ T{ bar-2 f 0 } select-tuples ] unit-test
    ;

[ setup-test-2-sql ] test-dbs

[ test-2 ] test-dbs


TUPLE: foo-3 id a ;
PERSISTENT: foo-3
{ "id" INTEGER +primary-key+ }
{ "a" VARCHAR } ;

TUPLE: bar-3 id b ;
PERSISTENT: bar-3
{ "id" INTEGER +primary-key+ }
{ "b" { foo-3 sequence } } ;

TUPLE: baz-3 id c ;
PERSISTENT: baz-3
{ "id" INTEGER +primary-key+ }
{ "c" { bar-3 sequence } } ;

: setup-test-3-sql ( -- )
    [ "drop table foo_3" sql-command ] try
    [ "drop table bar_3" sql-command ] try
    [ "drop table baz_3" sql-command ] try

    [ ] [ "create table foo_3(id integer primary key, a varchar, bar_3_id integer)" sql-command ] unit-test
    [ ] [ "create table bar_3(id integer primary key, baz_3_id integer)" sql-command ] unit-test
    [ ] [ "create table baz_3(id integer primary key)" sql-command ] unit-test

    [ ] [ "insert into foo_3(id, a, bar_3_id) values(0, 'first', 0);" sql-command ] unit-test
    [ ] [ "insert into foo_3(id, a, bar_3_id) values(1, 'second', 0);" sql-command ] unit-test

    [ ] [ "insert into foo_3(id, a, bar_3_id) values(2, 'third', 1);" sql-command ] unit-test
    [ ] [ "insert into foo_3(id, a, bar_3_id) values(3, 'fourth', 1);" sql-command ] unit-test

    [ ] [ "insert into bar_3(id, baz_3_id) values(0, 0);" sql-command ] unit-test
    [ ] [ "insert into bar_3(id, baz_3_id) values(1, 0);" sql-command ] unit-test

    [ ] [ "insert into baz_3(id) values(0);" sql-command ] unit-test

    [
        {
            { "0" "0" "0" "first" }
            { "0" "0" "1" "second" }
            { "0" "1" "2" "third" }
            { "0" "1" "3" "fourth" }
        }
    ] [ "select baz_3.id, bar_3.id, foo_3.id, foo_3.a
            from baz_3
                left join bar_3 on baz_3.id = bar_3.baz_3_id
                left join foo_3 on bar_3.id = foo_3.bar_3_id
                where baz_3.id = 0 order by baz_3.id, bar_3.id, foo_3.id"
        sql-query
    ] unit-test ;

[ setup-test-3-sql ] test-dbs
