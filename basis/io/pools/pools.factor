! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien continuations destructors io.sockets
kernel namespaces sequences ;
IN: io.pools

TUPLE: pool connections disposed expired ;

: check-pool ( pool -- )
    check-disposed
    dup expired>> expired? [
        31337 <alien> >>expired
        connections>> delete-all
    ] [ drop ] if ;

: <pool> ( class -- pool )
    new V{ } clone
        >>connections
        dup check-pool ; inline

M: pool dispose* connections>> dispose-each ;

: with-pool ( pool quot -- )
    [ pool swap with-variable ] curry with-disposal ; inline

TUPLE: return-connection-state conn pool ;

: return-connection ( conn pool -- )
    dup check-pool connections>> push ;

GENERIC: make-connection ( pool -- conn )

: new-connection ( pool -- )
    dup check-pool [ make-connection ] keep return-connection ;

: acquire-connection ( pool -- conn )
    dup check-pool
    [ dup connections>> empty? ] [ dup new-connection ] while
    connections>> pop ;

: (with-pooled-connection) ( conn pool quot -- )
    [ nip call ] [ drop return-connection ] 3bi ; inline

: with-pooled-connection ( pool quot -- )
    [ [ acquire-connection ] keep ] dip
    [ (with-pooled-connection) ] [ ] [ 2drop dispose ] cleanup ; inline

M: return-connection-state dispose
    [ conn>> ] [ pool>> ] bi return-connection ;

: return-connection-later ( db pool -- )
    \ return-connection-state boa &dispose drop ;

TUPLE: datagram-pool < pool addrspec ;

: <datagram-pool> ( addrspec -- pool )
    datagram-pool <pool> swap >>addrspec ;

M: datagram-pool make-connection addrspec>> <datagram> ;
