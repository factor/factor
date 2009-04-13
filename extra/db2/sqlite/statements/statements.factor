! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors db2.connections db2.sqlite.connections
db2.sqlite.ffi db2.sqlite.lib db2.statements destructors kernel
namespaces ;
IN: db2.sqlite.statements

TUPLE: sqlite-statement < statement ;

M: sqlite-db-connection <statement> ( string in out -- obj )
    sqlite-statement new-statement ;

M: sqlite-statement dispose
    handle>>
    [ [ sqlite3_reset drop ] [ sqlite-finalize ] bi ] when* ;

: sqlite-maybe-prepare ( statement -- statement )
    dup handle>> [
        db-connection get handle>> over sql>> sqlite-prepare
        >>handle
    ] unless ;
