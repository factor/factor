! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: continuations kernel ;
IN: db.errors

ERROR: db-error ;
TUPLE: sql-error location ;

ERROR: bad-schema ;

TUPLE: sql-unknown-error < sql-error message ;

: <sql-unknown-error> ( message -- error )
    f swap sql-unknown-error boa ;

TUPLE: sql-table-exists < sql-error table ;

: <sql-table-exists> ( table -- error )
    f swap sql-table-exists boa ;

TUPLE: sql-table-missing < sql-error table ;

: <sql-table-missing> ( table -- error )
    f swap sql-table-missing boa ;

TUPLE: sql-syntax-error < sql-error message ;

: <sql-syntax-error> ( message -- error )
    f swap sql-syntax-error boa ;

TUPLE: sql-function-exists < sql-error message ;

: <sql-function-exists> ( message -- error )
    f swap sql-function-exists boa ;

TUPLE: sql-function-missing < sql-error message ;

: <sql-function-missing> ( message -- error )
    f swap sql-function-missing boa ;

TUPLE: sql-database-exists < sql-error message ;

: <sql-database-exists> ( message -- error )
    f swap sql-database-exists boa ;

TUPLE: sql-index-exists < sql-error name ;

: <sql-index-exists> ( name -- error )
    f swap sql-index-exists boa ;

: ignore-table-exists ( quot -- )
    [ sql-table-exists? ] ignore-error ; inline

: ignore-table-missing ( quot -- )
    [ sql-table-missing? ] ignore-error ; inline

: ignore-function-exists ( quot -- )
    [ sql-function-exists? ] ignore-error ; inline

: ignore-function-missing ( quot -- )
    [ sql-function-missing? ] ignore-error ; inline

: ignore-database-exists ( quot -- )
    [ sql-database-exists? ] ignore-error ; inline

: ignore-index-exists ( quot -- )
    [ sql-index-exists? ] ignore-error ; inline
