! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations db2.debug orm.examples orm.queries
orm.tuples tools.test ;
IN: orm.queries.tests

[ [ \ user drop-table ] ignore-errors ] test-dbs

[ \ user create-table ] test-dbs
[ \ user drop-table ] test-dbs
