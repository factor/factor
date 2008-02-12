! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for license.
USING: alien continuations io kernel prettyprint sequences
db db.mysql.ffi ;
IN: db.mysql

TUPLE: mysql-db handle host user password db port ;
TUPLE: mysql-statement ;
TUPLE: mysql-result-set ;

M: mysql-db db-open ( mysql-db -- )
    ;

M: mysql-db dispose ( mysql-db -- )
    mysql-db-handle mysql_close ;

M: mysql-db <simple-statement> ( str -- statement )
    ;

M: mysql-db <prepared-statement> ( str -- statement )
    ;

M: mysql-statement prepare-statement ( statement -- )
    ;

M: mysql-statement bind-statement* ( statement -- )
    ;

M: mysql-statement rebind-statement ( statement -- )
    ;

M: mysql-statement execute-statement ( statement -- )
    ;

M: mysql-statement query-results ( query -- result-set )
    ;

M: mysql-result-set #rows ( result-set -- n )
    ;

M: mysql-result-set #columns ( result-set -- n )
    ;

M: mysql-result-set row-column ( result-set n -- obj )
    ;

M: mysql-result-set advance-row ( result-set -- ? )
    ;

M: mysql-db begin-transaction ( -- )
    ;

M: mysql-db commit-transaction ( -- )
    ;

M: mysql-db rollback-transaction ( -- )
    ;
