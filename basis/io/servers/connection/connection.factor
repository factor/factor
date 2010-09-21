! Copyright (C) 2003, 2010 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar combinators
combinators.short-circuit concurrency.combinators
concurrency.count-downs concurrency.flags
concurrency.semaphores continuations debugger destructors fry
io io.sockets io.sockets.secure io.streams.duplex io.styles
io.timeouts kernel logging make math math.parser namespaces
present prettyprint random sequences sets strings threads ;
FROM: namespaces => set ;
IN: io.servers.connection

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
server-stopped ;

SYMBOL: running-servers
running-servers [ HS{ } clone ] initialize

ERROR: server-already-running threaded-server ;

ERROR: server-not-running threaded-server ;

<PRIVATE

: must-be-running ( threaded-server -- threaded-server )
    dup running-servers get in? [ server-not-running ] unless ;

: must-not-be-running ( threaded-server -- threaded-server )
    dup running-servers get in? [ server-already-running ] when ;

: add-running-server ( threaded-server -- )
    must-not-be-running
    running-servers get adjoin ;

: remove-running-server ( threaded-server -- )
    ! must-be-running
    running-servers get delete ;

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

GENERIC: (>insecure) ( obj -- obj )

M: inet (>insecure) ;
M: inet4 (>insecure) ;
M: inet6 (>insecure) ;
M: local (>insecure) ;
M: integer (>insecure) internet-server ;
M: string (>insecure) internet-server ;
M: array (>insecure) [ (>insecure) ] map ;
M: f (>insecure) ;

: >insecure ( obj -- seq )
    (>insecure) dup sequence? [ 1array ] unless ;

: >secure ( addrspec -- addrspec' )
    >insecure
    [ dup { [ secure? ] [ not ] } 1|| [ <secure> ] unless ] map ;

: filter-ipv6 ( seq -- seq' )
    ipv6-supported? [ [ ipv6? not ] filter ] unless ;

: listen-on ( threaded-server -- addrspecs )
    [ secure>> >secure ] [ insecure>> >insecure ] bi append
    [ resolve-host ] map concat filter-ipv6 ;

: accepted-connection ( remote local -- )
    [
        [ "remote: " % present % ", " % ]
        [ "local: " % present % ]
        bi*
    ] "" make
    \ accepted-connection NOTICE log-message ;

: log-connection ( remote local -- )
    [ accepted-connection ]
    [ [ remote-address set ] [ local-address set ] bi* ]
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

: accept-loop ( server -- )
    [ accept-connection ] [ accept-loop ] bi ;

: start-accept-loop ( server -- ) accept-loop ;

\ start-accept-loop NOTICE add-error-logging

: init-server ( threaded-server -- threaded-server )
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
    dup dup listen-on [ no-ports-configured ] [ (make-servers) ] if-empty
    >>servers ;

: server-thread-name ( threaded-server addrspec -- string )
    [ name>> ] [ addr>> present ] bi* " server on " glue ;

: (start-server) ( threaded-server -- )
    init-server
    dup threaded-server [
        [ ] [ name>> ] bi
        [
            set-servers
            dup add-running-server
            dup servers>>
            [
                [ nip '[ _ [ start-accept-loop ] with-disposal ] ]
                [ server-thread-name ] 2bi spawn drop
            ] with each
        ] with-logging
    ] with-variable ;

PRIVATE>

: start-server ( threaded-server -- threaded-server )
    #! Only create a secure-context if we want to listen on
    #! a secure port, otherwise start-server won't work at
    #! all if SSL is not available.
    dup dup secure>> [
        dup secure-config>> [
            (start-server)
        ] with-secure-context
    ] [
        (start-server)
    ] if ;

: server-running? ( threaded-server -- ? )
    server-stopped>> [ value>> not ] [ f ] if* ;

: stop-server ( threaded-server -- )
    dup server-running? [
        [ [ f ] change-servers drop dispose-each ]
        [ remove-running-server ]
        [ server-stopped>> raise-flag ] tri
    ] [
        drop
    ] if ;

: stop-this-server ( -- )
    threaded-server get stop-server ;

: wait-for-server ( threaded-server -- )
    server-stopped>> wait-for-flag ;

: with-threaded-server ( threaded-server quot -- )
    over
    '[
        [ _ start-server threaded-server _ with-variable ]
        [ _ stop-server ]
        [ ] cleanup
    ] call ; inline

<PRIVATE

: first-port ( quot -- n/f )
    [ threaded-server get servers>> ] dip
    filter [ f ] [ first addr>> port>> ] if-empty ; inline

PRIVATE>

: secure-port ( -- n/f ) [ addr>> secure? ] first-port ;

: insecure-port ( -- n/f ) [ addr>> secure? not ] first-port ;

: secure-addr ( -- inet )
    threaded-server get servers>> [ addr>> secure? ] filter random ;

: insecure-addr ( -- inet )
    threaded-server get servers>> [ addr>> secure? not ] filter random addr>> ;
    
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
