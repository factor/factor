! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for license.
USING: alien continuations destructors io kernel prettyprint
sequences db db.mysql.ffi ;
IN: db.mysql

TUPLE: mysql-db handle host user password db port ;
TUPLE: mysql-statement ;
TUPLE: mysql-result-set ;

! M: mysql-db db-open ( mysql-db -- )
!    drop ;

M: mysql-db dispose ( mysql-db -- )
     mysql_close ;

M: mysql-db <simple-statement> ( str in out -- statement )
    3drop f ;

M: mysql-db <prepared-statement> ( str in out -- statement )
    3drop f ;

M: mysql-statement prepare-statement ( statement -- )
    drop ;

M: mysql-statement bind-statement* ( statement -- )
    drop ;

M: mysql-statement query-results ( query -- result-set )
    drop f ;

M: mysql-result-set #rows ( result-set -- n )
    drop 0 ;

M: mysql-result-set #columns ( result-set -- n )
    drop 0 ;

M: mysql-result-set row-column ( result-set n -- obj )
    2drop f ;

M: mysql-result-set advance-row ( result-set -- )
    drop ;

M: mysql-db begin-transaction ( -- )
    ;

M: mysql-db commit-transaction ( -- )
    ;

M: mysql-db rollback-transaction ( -- )
    ;
