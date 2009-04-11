! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors destructors fry kernel namespaces ;
IN: db2.connections

TUPLE: db-connection handle ;

GENERIC: db-open ( db -- db-connection )
HOOK: db-close db-connection ( handle -- )
HOOK: parse-db-error db-connection ( error -- error' )

M: db-connection dispose ( db-connection -- )
    [ db-close f ] change-handle drop ;

: with-db ( db quot -- )
    [ db-open db-connection dup ] dip
    '[ _ [ drop @ ] with-disposal ] with-variable ; inline
