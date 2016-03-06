! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors db2.connections db2.statements
io.encodings.string io.encodings.utf8 kernel
mysql.db2.connections mysql.db2.ffi mysql.db2.lib namespaces
sequences locals ;
IN: mysql.db2.statements

:: mysql-prepare ( stmt sql -- stmt )
    stmt sql utf8 encode dup length mysql_stmt_prepare
    [ stmt ] dip mysql-stmt-check-result stmt ;

: mysql-maybe-prepare ( statement -- statement )
    dup handle>> [
        db-connection get handle>> mysql_stmt_init
        over sql>> mysql-prepare >>handle
    ] unless ;

M: mysql-db-connection prepare-statement*
    mysql-maybe-prepare ;

M: mysql-db-connection bind-sequence
    drop ;

M: mysql-db-connection reset-statement
    [ handle>> mysql-reset-statement ] keep ;

M: mysql-db-connection dispose-statement
    f >>handle drop ;

! M: mysql-db-connection next-bind-index "?" ;

! M: mysql-db-connection init-bind-index ;


