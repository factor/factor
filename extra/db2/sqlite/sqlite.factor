! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: constructors db2.connections ;
IN: db2.sqlite

TUPLE: sqlite-db path ;
CONSTRUCTOR: sqlite-db ( path -- sqlite-db ) ;

TUPLE: sqlite-db-connection < db-connection ;

: <sqlite-db-connection> ( handle -- db-connection )
    sqlite-db-connection new-db-connection ;
