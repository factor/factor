! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel continuations fry words ;
IN: db.errors

ERROR: db-error ;
ERROR: sql-error location ;

ERROR: bad-schema ;

ERROR: sql-unknown-error < sql-error message ;
: <sql-unknown-error> ( message -- error )
    \ sql-unknown-error new
        swap >>message ;

ERROR: sql-table-exists < sql-error table ;
: <sql-table-exists> ( table -- error )
    \ sql-table-exists new
        swap >>table ;

ERROR: sql-table-missing < sql-error table ;
: <sql-table-missing> ( table -- error )
    \ sql-table-missing new
        swap >>table ;

ERROR: sql-syntax-error < sql-error message ;
: <sql-syntax-error> ( message -- error )
    \ sql-syntax-error new
        swap >>message ;

ERROR: sql-function-exists < sql-error message ;
: <sql-function-exists> ( message -- error )
    \ sql-function-exists new
        swap >>message ;

ERROR: sql-function-missing < sql-error message ;
: <sql-function-missing> ( message -- error )
    \ sql-function-missing new
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
