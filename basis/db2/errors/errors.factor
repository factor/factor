! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: constructors continuations db2.connections fry kernel ;
IN: db2.errors

ERROR: db-error ;

TUPLE: sql-error location ;
HOOK: parse-sql-error db-connection ( error -- error' )

TUPLE: sql-unknown-error < sql-error message ;
CONSTRUCTOR: <sql-unknown-error> sql-unknown-error ( message -- error ) ;

TUPLE: sql-table-exists < sql-error table ;
CONSTRUCTOR: <sql-table-exists> sql-table-exists ( table -- error ) ;

TUPLE: sql-table-missing < sql-error table ;
CONSTRUCTOR: <sql-table-missing> sql-table-missing ( table -- error ) ;

TUPLE: sql-syntax-error < sql-error message ;
CONSTRUCTOR: <sql-syntax-error> sql-syntax-error ( message -- error ) ;

TUPLE: sql-function-exists < sql-error message ;
CONSTRUCTOR: <sql-function-exists> sql-function-exists ( message -- error ) ;

TUPLE: sql-function-missing < sql-error message ;
CONSTRUCTOR: <sql-function-missing> sql-function-missing ( message -- error ) ;

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
