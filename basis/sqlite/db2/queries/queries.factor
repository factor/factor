! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays db2.connections db2.queries db2.statements
db2.types kernel math namespaces sequences sqlite.db2.connections ;
IN: sqlite.db2.queries

TUPLE: sqlite-object < sql-object table-type internal-name table-name rootpage sql ;
TUPLE: sqlite-column < sql-column cid name type notnull dflt_value pk ;

M: sqlite-db-connection current-db-name 
    db-connection get db>> path>> ;

: sqlite-table-info-statement ( string -- statement )
    [ <statement> ] dip
        sanitize-string
        "pragma table_info('" "');" surround >>sql ;

M: sqlite-db-connection sql-object-class sqlite-object ;
M: sqlite-db-connection sql-column-class sqlite-column ;
M: sqlite-db-connection databases-statement { } ;

M: sqlite-db-connection database-table-columns-statement
    nip
    sqlite-table-info-statement
        { INTEGER VARCHAR VARCHAR INTEGER VARCHAR INTEGER } >>out ;

M: sqlite-db-connection database-tables-statement
    drop
    <statement>
        "SELECT * FROM sqlite_master" >>sql ;
