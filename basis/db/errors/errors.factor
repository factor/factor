! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel continuations fry words ;
IN: db.errors

ERROR: db-error ;
TUPLE: sql-error location ;

ERROR: bad-schema ;

TUPLE: sql-unknown-error < sql-error message ;
: <sql-unknown-error> ( message -- error )
    \ sql-unknown-error new
        swap >>message ;

TUPLE: sql-table-exists < sql-error table ;
: <sql-table-exists> ( table -- error )
    \ sql-table-exists new
        swap >>table ;

TUPLE: sql-table-missing < sql-error table ;
: <sql-table-missing> ( table -- error )
    \ sql-table-missing new
        swap >>table ;

TUPLE: sql-syntax-error < sql-error message ;
: <sql-syntax-error> ( message -- error )
    \ sql-syntax-error new
        swap >>message ;

TUPLE: sql-function-exists < sql-error message ;
: <sql-function-exists> ( message -- error )
    \ sql-function-exists new
        swap >>message ;

TUPLE: sql-function-missing < sql-error message ;
: <sql-function-missing> ( message -- error )
    \ sql-function-missing new
        swap >>message ;

TUPLE: sql-database-exists < sql-error message ;
: <sql-database-exists> ( message -- error )
    \ sql-database-exists new
        swap >>message ;

: ignore-error ( quot word -- )
    '[ dup _ execute [ drop ] [ rethrow ] if ] recover ; inline

: ignore-table-exists ( quot -- )
    \ sql-table-exists? ignore-error ; inline

: ignore-table-missing ( quot -- )
    \ sql-table-missing? ignore-error ; inline

: ignore-function-exists ( quot -- )
    \ sql-function-exists? ignore-error ; inline

: ignore-function-missing ( quot -- )
    \ sql-function-missing? ignore-error ; inline

: ignore-database-exists ( quot -- )
    \ sql-database-exists? ignore-error ; inline
