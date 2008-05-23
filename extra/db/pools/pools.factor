! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel arrays namespaces sequences continuations
io.pools db ;
IN: db.pools

TUPLE: db-pool < pool db params ;

: <db-pool> ( db params -- pool )
    db-pool <pool>
        swap >>params
        swap >>db ;

: with-db-pool ( db params quot -- )
    >r <db-pool> r> with-pool ; inline

M: db-pool make-connection ( pool -- )
    [ db>> ] [ params>> ] bi make-db db-open ;

: with-pooled-db ( pool quot -- )
    [ db swap with-variable ] curry with-pooled-connection ; inline
