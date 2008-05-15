! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel arrays namespaces sequences continuations
destructors db ;
IN: db.pooling

TUPLE: pool db params connections ;

: <pool> ( db params -- pool )
    V{ } clone pool boa ;

M: pool dispose [ dispose-each f ] change-connections drop ;

: with-db-pool ( db params quot -- )
    >r <pool> r> [ pool swap with-variable ] curry with-disposal ; inline

TUPLE: return-connection db pool ;

: return-connection ( db pool -- )
    connections>> push ;

: new-connection ( pool -- )
    [ [ db>> ] [ params>> ] bi make-db db-open ] keep
    return-connection ;

: acquire-connection ( pool -- db )
    [ dup connections>> empty? ] [ dup new-connection ] [ ] while
    connections>> pop ;

: (with-pooled-connection) ( db pool quot -- )
    [ >r drop db r> with-variable ]
    [ drop return-connection ]
    3bi ; inline

: with-pooled-connection ( pool quot -- )
    >r [ acquire-connection ] keep r>
    [ (with-pooled-connection) ] [ ] [ 2drop dispose ] cleanup ; inline

M: return-connection dispose
    [ db>> ] [ pool>> ] bi return-connection ;

: return-connection-later ( db pool -- )
    \ return-connection boa &dispose drop ;
