! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors destructors fry kernel namespaces ;
IN: db2.connections

TUPLE: db-connection handle ;

: new-db-connection ( handle class -- db-connection )
    new
        swap >>handle ; inline

GENERIC: db-open ( db -- db-connection )
GENERIC: db-close ( handle  -- )

M: db-connection dispose ( db-connection -- )
    [ db-close ] [ f >>handle drop ] bi ;

: with-db ( db quot -- )
    [ db-open db-connection over ] dip
    '[ _ [ drop @ ] with-disposal ] with-variable ; inline
