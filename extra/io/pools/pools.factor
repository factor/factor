! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel arrays namespaces sequences continuations
destructors io.sockets ;
IN: io.pools

TUPLE: pool connections disposed ;

: <pool> ( class -- pool )
    new V{ } clone >>connections ; inline

M: pool dispose* connections>> dispose-each ;

: with-pool ( pool quot -- )
    [ pool swap with-variable ] curry with-disposal ; inline

TUPLE: return-connection conn pool ;

: return-connection ( conn pool -- )
    dup check-disposed connections>> push ;

GENERIC: make-connection ( pool -- conn )

: new-connection ( pool -- )
    [ make-connection ] keep return-connection ;

: acquire-connection ( pool -- conn )
    dup check-disposed
    [ dup connections>> empty? ] [ dup new-connection ] [ ] while
    connections>> pop ;

: (with-pooled-connection) ( conn pool quot -- )
    [ nip call ] [ drop return-connection ] 3bi ; inline

: with-pooled-connection ( pool quot -- )
    >r [ acquire-connection ] keep r>
    [ (with-pooled-connection) ] [ ] [ 2drop dispose ] cleanup ; inline

M: return-connection dispose
    [ conn>> ] [ pool>> ] bi return-connection ;

: return-connection-later ( db pool -- )
    \ return-connection boa &dispose drop ;

TUPLE: datagram-pool < pool addrspec ;

: <datagram-pool> ( addrspec -- pool )
    datagram-pool <pool> swap >>addrspec ;

M: datagram-pool make-connection addrspec>> <datagram> ;
