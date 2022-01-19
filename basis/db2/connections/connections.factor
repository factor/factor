! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors destructors fry kernel namespaces ;
IN: db2.connections

TUPLE: db-connection < disposable handle db ;

: new-db-connection ( handle class -- db-connection )
    new-disposable
        swap >>handle ; inline

GENERIC: db>db-connection-generic ( db -- db-connection )

: db>db-connection ( db -- db-connection )
    [ db>db-connection-generic ] keep >>db ; inline

: with-db ( db quot -- )
    [ db>db-connection db-connection over ] dip
    '[ _ [ drop @ ] with-disposal ] with-variable ; inline
