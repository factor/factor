! Copyright (C) 2003, 2010 Slava Pestov, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar concurrency.flags
concurrency.semaphores continuations destructors io io.sockets
io.sockets.secure io.streams.duplex io.styles io.timeouts kernel
logging make math namespaces present prettyprint random
sequences sets strings threads ;
IN: io.servers

TUPLE: threaded-server < identity-tuple
name
log-level
secure
insecure
secure-config
servers
max-connections
semaphore
timeout
encoding
handler
server-stopped
secure-context ;

SYMBOL: running-servers
running-servers [ HS{ } clone ] initialize

ERROR: server-not-running threaded-server ;

ERROR: server-already-running threaded-server ;

<PRIVATE

: add-running-server ( threaded-server running-servers -- )
    dupd ?adjoin [ drop ] [ server-already-running ] if ;

: remove-running-server ( threaded-server running-servers -- )
    dupd ?delete [ drop ] [ server-not-running ] if ;

PRIVATE>

: local-server ( port -- addrspec ) "localhost" swap <inet> ;

: internet-server ( port -- addrspec ) f swap <inet> ;

: new-threaded-server ( encoding class -- threaded-server )
    new
        "server" >>name
        DEBUG >>log-level
        <secure-config> >>secure-config
        1 minutes >>timeout
        [ "No handler quotation" throw ] >>handler
        swap >>encoding ;

: <threaded-server> ( encoding -- threaded-server )
    threaded-server new-threaded-server ;

GENERIC: handle-client* ( threaded-server -- )

<PRIVATE

GENERIC: >insecure ( obj -- obj )

M: inet >insecure 1array ;
M: inet4 >insecure 1array ;
M: inet6 >insecure 1array ;
M: local >insecure 1array ;
M: integer >insecure internet-server 1array ;
M: string >insecure internet-server 1array ;
M: array >insecure [ >insecure ] map concat ;
M: f >insecure ;

: >secure ( addrspec -- addrspec' )
    >insecure [ dup secure? [ f <secure> ] unless ] map ;

: configurable-addrspecs ( addrspecs -- addrspecs' )
    [ inet6? not ipv6-supported? or ] filter ;

: listen-on ( threaded-server -- addrspecs )
    [ secure>> ssl-supported? [ >secure ] [ drop { } ] if ]
    [ insecure>> >insecure ] bi append
    [ resolve-host ] map concat configurable-addrspecs ;

: accepted-connection ( remote local -- )
    [
        [ "remote: " % present % ", " % ]
        [ "local: " % present % ]
        bi*
    ] "" make
    \ accepted-connection NOTICE log-message ;

: log-connection ( remote local -- )
    [ accepted-connection ]
    [ [ remote-address namespaces:set ] [ local-address namespaces:set ] bi* ]
    2bi ;

M: threaded-server handle-client* handler>> call( -- ) ;

: handle-client ( client remote local -- )
    '[
        _ _ log-connection
        threaded-server get
        [ timeout>> timeouts ] [ handle-client* ] bi
    ] with-stream ;

\ handle-client NOTICE add-error-logging

: client-thread-name ( addrspec -- string )
    [ threaded-server get name>> ] dip
    unparse-short " connection from " glue ;

: (accept-connection) ( server -- )
    [ accept ] [ addr>> ] bi
    [ '[ _ _ _ handle-client ] ]
    [ drop client-thread-name ] 2bi
    spawn drop ;

: accept-connection ( server -- )
    threaded-server get semaphore>>
    [ [ (accept-connection) ] with-semaphore ]
    [ (accept-connection) ]
    if* ;

: with-existing-secure-context ( threaded-server quot -- )
    [ secure-context>> secure-context ] dip with-variable ; inline

: accept-loop ( server -- )
    [ accept-connection ] [ accept-loop ] bi ;

: start-accept-loop ( threaded-server server -- )
    '[ _ accept-loop ] with-existing-secure-context ;

\ start-accept-loop NOTICE add-error-logging

: create-secure-context ( threaded-server -- threaded-server )
    dup secure>> ssl-supported? and [
        dup secure-config>> <secure-context> >>secure-context
    ] when ;

: init-server ( threaded-server -- threaded-server )
    create-secure-context
    <flag> >>server-stopped
    dup semaphore>> [
        dup max-connections>> [
            <semaphore> >>semaphore
        ] when*
    ] unless ;

ERROR: no-ports-configured threaded-server ;

: (make-servers) ( theaded-server addrspecs -- servers )
    swap encoding>>
    '[ [ _ <server> |dispose ] map ] with-destructors ;

: set-servers ( threaded-server -- threaded-server )
    dup [
        dup dup listen-on
        [ no-ports-configured ] [ (make-servers) ] if-empty
        >>servers
    ] with-existing-secure-context ;

: server-thread-name ( threaded-server addrspec -- string )
    [ name>> ] [ addr>> present ] bi* " server on " glue ;

PRIVATE>

: start-server ( threaded-server -- threaded-server )
    init-server
    [
        dup threaded-server [
            [ ] [ name>> ] bi
            [
                set-servers
                dup running-servers get add-running-server
                dup servers>>
                [
                    [ '[ _ _ [ start-accept-loop ] with-disposal ] ]
                    [ server-thread-name ] 2bi spawn drop
                ] with each
            ] with-logging
        ] with-variable
    ] keep ;

: server-running? ( threaded-server -- ? )
    server-stopped>> [ value>> not ] [ f ] if* ;

: stop-server ( threaded-server -- )
    dup server-running? [
        [ running-servers get remove-running-server ]
        [
            [
                [ secure-context>> [ &dispose drop ] when* ]
                [ [ f ] change-servers drop dispose-each ] bi
            ] with-destructors
        ]
        [ server-stopped>> raise-flag ] tri
    ] [
        drop
    ] if ;

: stop-this-server ( -- )
    threaded-server get stop-server ;

: wait-for-server ( threaded-server -- )
    server-stopped>> wait-for-flag ;

: with-threaded-server ( threaded-server quot -- )
    [ start-server ] dip over
    '[
        [ _ threaded-server _ with-variable ]
        [ _ stop-server ]
        finally
    ] call ; inline

<PRIVATE

GENERIC: connect-addr ( addrspec -- addrspec )

M: inet4 connect-addr [ "127.0.0.1" ] dip port>> <inet4> ;

M: inet6 connect-addr [ "::1" ] dip port>> <inet6> ;

M: secure connect-addr addrspec>> connect-addr f <secure> ;

M: local connect-addr ;

PRIVATE>

: server-addrs ( -- addrspecs )
    threaded-server get servers>> [ addr>> connect-addr ] map ;

: secure-addr ( -- addrspec )
    server-addrs [ secure? ] filter random ;

: insecure-addr ( -- addrspec )
    server-addrs [ secure? ] reject random ;

: server. ( threaded-server -- )
    [ [ "=== " write name>> ] [ ] bi write-object nl ]
    [ servers>> [ addr>> present print ] each ] bi ;

: all-servers ( -- sequence )
    running-servers get-global members ;

: get-servers-named ( string -- sequence )
    [ all-servers ] dip '[ name>> _ = ] filter ;

: servers. ( -- )
    all-servers [ server. ] each ;

: stop-all-servers ( -- )
    all-servers [ stop-server ] each ;
