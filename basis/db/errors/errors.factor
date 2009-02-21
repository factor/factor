! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel db.private ;
IN: db.errors

HOOK: parse-db-error db-connection ( error -- error' )

ERROR: db-error ;
ERROR: sql-error ;

ERROR: table-exists ;
ERROR: bad-schema ;

ERROR: sql-syntax-error error ;

ERROR: sql-table-exists table ;
C: <sql-table-exists> sql-table-exists

ERROR: sql-table-missing table ;
C: <sql-table-missing> sql-table-missing
