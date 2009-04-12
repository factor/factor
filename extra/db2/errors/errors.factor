! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel continuations fry words constructors
db2.connections ;
IN: db2.errors

ERROR: db-error ;
ERROR: sql-error location ;
HOOK: parse-sql-error db-connection ( error -- error' )

ERROR: sql-unknown-error < sql-error message ;
CONSTRUCTOR: sql-unknown-error ( message -- error ) ;

ERROR: sql-table-exists < sql-error table ;
CONSTRUCTOR: sql-table-exists ( table -- error ) ;

ERROR: sql-table-missing < sql-error table ;
CONSTRUCTOR: sql-table-missing ( table -- error ) ;

ERROR: sql-syntax-error < sql-error message ;
CONSTRUCTOR: sql-syntax-error ( message -- error ) ;

ERROR: sql-function-exists < sql-error message ;
CONSTRUCTOR: sql-function-exists ( message -- error ) ;

ERROR: sql-function-missing < sql-error message ;
CONSTRUCTOR: sql-function-missing ( message -- error ) ;

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
