! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar continuations io
io.encodings.binary io.servers.connection io.sockets
io.streams.duplex kernel locals math math.ranges multiline
namespaces prettyprint random sequences sets splitting threads
tools.continuations ;
IN: managed-server

SYMBOL: client

TUPLE: managed-server < threaded-server clients ;

TUPLE: managed-client input-stream output-stream local-address
remote-address username ;

GENERIC: login ( managed-server -- username )
GENERIC: handle-managed-client* ( threaded-server -- )

ERROR: already-logged-in username ;
ERROR: bad-login username ;

<PRIVATE

: <managed-client> ( username -- managed-client )
    managed-client new
        swap >>username
        input-stream get >>input-stream
        output-stream get >>output-stream
        local-address get >>local-address
        remote-address get >>remote-address ;

: check-logged-in ( username -- username )
    dup threaded-server get clients>> key? [ already-logged-in ] when ;

: add-managed-client ( managed-client -- )
    dup username>>
    threaded-server get clients>> set-at ;

: delete-managed-client ( -- )
    client get username>>
    threaded-server get clients>> delete-at ;

: handle-managed-client ( -- )
    [ [ threaded-server get handle-managed-client* t ] loop ]
    [ delete-managed-client ]
    [ ] cleanup ;

PRIVATE>

M: managed-server login drop readln ;

M: managed-server handle-client*
    login <managed-client>
    [ client set ] [ add-managed-client ] bi
    handle-managed-client ;

: new-managed-server ( port name class -- server )
    new-threaded-server
        swap >>name
        swap >>insecure
        f >>timeout
        H{ } clone >>clients ; inline
