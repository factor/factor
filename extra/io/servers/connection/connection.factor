! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations destructors kernel math math.parser
namespaces parser sequences strings prettyprint debugger
quotations combinators logging calendar assocs
fry accessors arrays io io.sockets io.encodings.ascii
io.sockets.secure io.files io.streams.duplex io.timeouts
io.encodings threads concurrency.combinators
concurrency.semaphores combinators.short-circuit ;
IN: io.servers.connection

TUPLE: threaded-server
name
secure insecure
secure-config
sockets
max-connections
semaphore
timeout
encoding
handler ;

: local-server ( port -- addrspec ) "localhost" swap <inet> ;

: internet-server ( port -- addrspec ) f swap <inet> ;

: new-threaded-server ( class -- threaded-server )
    new
        "server" >>name
        ascii >>encoding
        1 minutes >>timeout
        V{ } clone >>sockets
        <secure-config> >>secure-config
        [ "No handler quotation" throw ] >>handler ; inline

: <threaded-server> ( -- threaded-server )
    threaded-server new-threaded-server ;

SYMBOL: remote-address

GENERIC: handle-client* ( server -- )

<PRIVATE

: >insecure ( addrspec -- addrspec' )
    dup { [ integer? ] [ string? ] } 1|| [ internet-server ] when ;

: >secure ( addrspec -- addrspec' )
    >insecure
    dup { [ secure? ] [ not ] } 1|| [ <secure> ] unless ;

: listen-on ( threaded-server -- addrspecs )
    [ secure>> >secure ] [ insecure>> >insecure ] bi
    [ resolve-host ] bi@ append ;

LOG: accepted-connection NOTICE

: log-connection ( remote local -- )
    [ [ remote-address set ] [ local-address set ] bi* ]
    [ 2array accepted-connection ]
    2bi ;

M: threaded-server handle-client* handler>> call ;

: handle-client ( client remote local -- )
    '[
        , , log-connection
        threaded-server get
        [ timeout>> timeouts ] [ handle-client* ] bi
    ] with-stream ;

: thread-name ( server-name addrspec -- string )
    unparse " connection from " swap 3append ;

: accept-connection ( server -- )
    [ accept ] [ addr>> ] bi
    [ '[ , , , handle-client ] ]
    [ drop threaded-server get name>> swap thread-name ] 2bi
    spawn drop ;

: accept-loop ( server -- )
    [
        threaded-server get semaphore>>
        [ [ accept-connection ] with-semaphore ]
        [ accept-connection ]
        if*
    ] [ accept-loop ] bi ; inline

: start-accept-loop ( server -- )
    threaded-server get encoding>> <server>
    [ threaded-server get sockets>> push ]
    [ [ accept-loop ] with-disposal ]
    bi ;

\ start-accept-loop ERROR add-error-logging

: init-server ( threaded-server -- threaded-server )
    dup semaphore>> [
        dup max-connections>> [
            <semaphore> >>semaphore
        ] when*
    ] unless ;

PRIVATE>

: start-server ( threaded-server -- )
    init-server
    dup secure-config>> [
        dup threaded-server [
            dup name>> [
                listen-on [
                    start-accept-loop
                ] parallel-each
            ] with-logging
        ] with-variable
    ] with-secure-context ;

: stop-server ( -- )
    threaded-server get [ f ] change-sockets drop dispose-each ;

GENERIC: port ( addrspec -- n )

M: integer port ;

M: object port port>> ;

: secure-port ( -- n )
    threaded-server get dup [ secure>> port ] when ;

: insecure-port ( -- n )
    threaded-server get dup [ insecure>> port ] when ;
