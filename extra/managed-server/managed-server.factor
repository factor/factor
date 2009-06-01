! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar continuations destructors io
io.encodings.binary io.servers.connection io.sockets
io.streams.duplex fry kernel locals math math.ranges multiline
namespaces prettyprint random sequences sets splitting threads
tools.continuations ;
IN: managed-server

TUPLE: managed-server < threaded-server clients ;

TUPLE: managed-client
input-stream output-stream local-address remote-address
username object quit? ;

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
    clients [ drop username = not ] assoc-filter ;
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

: check-logged-in ( username -- username )
    dup clients key? [ handle-already-logged-in ] when ;

: add-managed-client ( -- )
    client username check-logged-in clients set-at ;

: delete-managed-client ( -- )
    username server clients>> delete-at ;

: handle-managed-client ( -- )
    handle-login <managed-client> managed-client set
    add-managed-client handle-client-join
    [ handle-managed-client* client quit?>> not ] loop ;

PRIVATE>

M: managed-server handle-client*
    managed-server set
    [ handle-managed-client ]
    [ delete-managed-client handle-client-disconnect ]
    [ ] cleanup ;

: new-managed-server ( port name encoding class -- server )
    new-threaded-server
        swap >>name
        swap >>insecure
        f >>timeout
        H{ } clone >>clients ; inline
