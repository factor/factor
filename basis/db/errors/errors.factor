! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel ;
IN: db.errors

ERROR: db-error ;
ERROR: sql-error location ;

ERROR: bad-schema ;

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
