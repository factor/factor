! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: db2.connections db2.statements db2.sqlite.connections
db2.sqlite.lib ;
IN: db2.sqlite.statements

TUPLE: sqlite-statement < statement ;

M: sqlite-db-connection <statement> ( string in out -- obj )
    sqlite-statement new-statement ;

