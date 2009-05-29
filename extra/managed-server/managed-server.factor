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
username object ;

HOOK: login threaded-server ( -- username )
HOOK: handle-already-logged-in managed-server ( -- )
HOOK: handle-client-join managed-server ( -- )
HOOK: handle-client-disconnect managed-server ( -- )
HOOK: handle-managed-client* managed-server ( -- )

M: managed-server handle-already-logged-in ;
M: managed-server handle-client-join ;
M: managed-server handle-client-disconnect ;
M: managed-server handle-managed-client* ;

: server ( -- managed-client ) managed-server get ;
: client ( -- managed-client ) managed-client get ;
: clients ( -- assoc ) server clients>> ;
: client-streams ( -- assoc ) clients values ;
: username ( -- string ) client username>> ;

: send-everyone ( seq -- )
    client-streams swap '[
        output-stream>> [ _ print flush ] with-output-stream*
    ] each ;

: print-client ( string -- )
    client output-stream>>
    [ stream-print ] [ stream-flush ] bi ;

ERROR: already-logged-in username ;
ERROR: normal-quit ;

<PRIVATE

: <managed-client> ( username -- managed-client )
    managed-client new
        swap >>username
        input-stream get >>input-stream
        output-stream get >>output-stream
        local-address get >>local-address
        remote-address get >>remote-address ;

: check-logged-in ( username -- username )
    dup server clients>> key? [
        [ server ] dip
        [ handle-already-logged-in ] [ already-logged-in ] bi
    ] when ;

: add-managed-client ( -- )
    client username check-logged-in clients set-at ;

: delete-managed-client ( -- )
    username server clients>> delete-at ;

: handle-managed-client ( -- )
    [ [ handle-managed-client* t ] loop ]
    [ delete-managed-client handle-client-disconnect ]
    [ ] cleanup ;

PRIVATE>

M: managed-server login readln ;

M: managed-server handle-client*
    managed-server set
    login <managed-client> managed-client set
    add-managed-client
    handle-client-join handle-managed-client ;

: new-managed-server ( port name class -- server )
    new-threaded-server
        swap >>name
        swap >>insecure
        f >>timeout
        H{ } clone >>clients ; inline
