! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors db2.connections fry io.pools kernel
namespaces ;
IN: db2.pools

TUPLE: db-pool < pool db ;

: <db-pool> ( db -- pool )
    db-pool <pool>
        swap >>db ;

: with-db-pool ( db quot -- )
    [ <db-pool> ] dip with-pool ; inline

M: db-pool make-connection ( pool -- )
    db>> db-open ;

: with-pooled-db ( pool quot -- )
    '[ db-connection _ with-variable ] with-pooled-connection ; inline
