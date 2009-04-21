! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors ;
IN: db2.sqlite.db

TUPLE: sqlite-db path ;

: <sqlite-db> ( path -- sqlite-db )
    sqlite-db new
        swap >>path ;


