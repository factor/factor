! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for license.
USING: alien continuations io kernel prettyprint sequences
db ;
IN: db.mysql

TUPLE: mysql-db handle host user password db port ;

M: mysql-db db-open ( mysql-db -- )
    ;

M: mysql-db dispose ( mysql-db -- )
    mysql-db-handle mysql_close ;


