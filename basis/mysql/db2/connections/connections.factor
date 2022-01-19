! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators db2.connections destructors kernel
mysql.db2 mysql.db2.ffi mysql.db2.lib ;
IN: mysql.db2.connections

TUPLE: mysql-db-connection < db-connection ;

: <mysql-db-connection> ( handle -- db-connection )
    mysql-db-connection new-db-connection ; inline

M: mysql-db db>db-connection-generic ( db -- db-connection )
    {
        [ host>> ]
        [ username>> ]
        [ password>> ]
        [ database>> ]
        [ port>> ]
    } cleave mysql-connect <mysql-db-connection> ;

M: mysql-db-connection dispose*
    [ handle>> mysql_close ] [ f >>handle drop ] bi ;
