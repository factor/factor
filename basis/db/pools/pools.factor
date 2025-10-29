! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors db io.pools kernel namespaces ;
IN: db.pools

TUPLE: db-pool < pool db ;

: <db-pool> ( db -- pool )
    db-pool <pool>
        swap >>db ;

: with-db-pool ( db quot -- )
    [ <db-pool> ] dip with-pool ; inline

M: db-pool make-connection
    db>> db-open ;

: with-db-pooled-connection ( pool quot -- )
    '[ db-connection _ with-variable ] with-pooled-connection ; inline
