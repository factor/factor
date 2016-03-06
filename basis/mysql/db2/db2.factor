! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences vocabs vocabs.loader ;
IN: mysql.db2

TUPLE: mysql-db host username password database port ;

: <mysql-db> ( -- db )
    f f f f 0 mysql-db boa ;

{
    "mysql.db2.ffi"
    "mysql.db2.lib"
    "mysql.db2.connections"
    "mysql.db2.statements"
    "mysql.db2.result-sets"
} [ require ] each
