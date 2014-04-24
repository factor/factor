! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: db2 db2.debug db2.queries debugger kernel sequences
tools.test ;
IN: db2.queries.tests

: test-table-exists ( -- )
    [ "drop table table_omg;" sql-command ] try
    [ f ] [ "table_omg" table-exists? ] unit-test
    [ ] [ "create table table_omg(id integer);" sql-command ] unit-test
    [ t ] [ "table_omg" table-exists? ] unit-test
    [ t ] [ "default_person" table-columns empty? not ] unit-test

    [ ] [ "factor-test" database-tables drop ] unit-test
    [ ] [ databases drop ] unit-test ;

[ test-table-exists ] test-dbs
