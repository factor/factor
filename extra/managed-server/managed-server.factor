! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs continuations io io.servers io.sockets
kernel namespaces sequences ;
IN: managed-server

TUPLE: managed-server < threaded-server clients ;

TUPLE: managed-client
input-stream output-stream local-address remote-address
username object quit? logged-in? ;

HOOK: handle-login threaded-server ( -- username )
HOOK: handle-managed-client* managed-server ( -- )
HOOK: handle-already-logged-in managed-server ( -- )
HOOK: handle-client-join managed-server ( -- )
HOOK: handle-client-disconnect managed-server ( -- )

ERROR: already-logged-in username ;

M: managed-server handle-already-logged-in already-logged-in ;
M: managed-server handle-client-join ;
M: managed-server handle-client-disconnect ;

: server ( -- managed-client ) managed-server get ;
: client ( -- managed-client ) managed-client get ;
: clients ( -- assoc ) server clients>> ;
: client-streams ( -- assoc ) clients values ;
: username ( -- string ) client username>> ;
: everyone-else ( -- assoc )
    clients [ drop username = ] assoc-reject ;
: everyone-else-streams ( -- assoc ) everyone-else values ;

ERROR: no-such-client username ;

<PRIVATE

: (send-client) ( managed-client seq -- )
    [ output-stream>> ] dip '[ _ print flush ] with-output-stream* ;

PRIVATE>

: send-client ( seq username -- )
    clients ?at [ no-such-client ] [ (send-client) ] if ;

: send-everyone ( seq -- )
    [ client-streams ] dip '[ _ (send-client) ] each ;

: send-everyone-else ( seq -- )
    [ everyone-else-streams ] dip '[ _ (send-client) ] each ;

<PRIVATE

: <managed-client> ( username -- managed-client )
    managed-client new
        swap >>username
        input-stream get >>input-stream
        output-stream get >>output-stream
        local-address get >>local-address
        remote-address get >>remote-address ;

: maybe-login-client ( -- )
    username clients key? [
        handle-already-logged-in
    ] [
        t client logged-in?<<
        client username clients set-at
    ] if ;

: when-logged-in ( quot -- )
    client logged-in?>> [ call ] [ drop ] if ; inline

: delete-managed-client ( -- )
    [ username server clients>> delete-at ] when-logged-in ;

: handle-managed-client ( -- )
    handle-login <managed-client> managed-client namespaces:set
    maybe-login-client [
        handle-client-join
        [ handle-managed-client* client quit?>> not ] loop
    ] when-logged-in ;

: cleanup-client ( -- )
    [
        delete-managed-client
        handle-client-disconnect
    ] when-logged-in ;

PRIVATE>

M: managed-server handle-client*
    managed-server namespaces:set
    [ handle-managed-client ]
    [ cleanup-client ]
    finally ;

: new-managed-server ( port name encoding class -- server )
    new-threaded-server
        swap >>name
        swap >>insecure
        f >>timeout
        H{ } clone >>clients ; inline

: new-managed-server* ( encoding class -- server )
    new-threaded-server
        f >>timeout
        H{ } clone >>clients ; inline
