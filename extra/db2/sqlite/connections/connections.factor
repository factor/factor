! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators db2.connections db2.sqlite
db2.sqlite.errors db2.sqlite.lib kernel db2.errors ;
IN: db2.sqlite.connections

TUPLE: sqlite-db-connection < db-connection ;

: <sqlite-db-connection> ( handle -- db-connection )
    sqlite-db-connection new-db-connection ;

M: sqlite-db db-open ( db -- db-connection )
    path>> sqlite-open <sqlite-db-connection> ;

M: sqlite-db-connection db-close ( db-connection -- )
    handle>> sqlite-close ;

M: sqlite-db-connection parse-sql-error ( error -- error' )
    dup n>> {
        { 1 [ string>> parse-sqlite-sql-error ] }
        [ drop ]
    } case ;
