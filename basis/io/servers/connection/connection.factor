! Copyright (C) 2003, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations destructors kernel math math.parser
namespaces parser sequences strings prettyprint
quotations combinators logging calendar assocs present
fry accessors arrays io io.sockets io.encodings.ascii
io.sockets.secure io.files io.streams.duplex io.timeouts
io.encodings threads make concurrency.combinators
concurrency.semaphores concurrency.flags
combinators.short-circuit ;
IN: io.servers.connection

TUPLE: threaded-server
{ name initial: "server" }
{ log-level initial: DEBUG }
secure insecure
{ secure-config initial-quot: [ <secure-config> ] }
{ sockets initial-quot: [ V{ } clone ] }
max-connections
semaphore
{ timeout initial-quot: [ 1 minutes ] }
encoding
{ handler initial: [ "No handler quotation" throw ] }
{ ready initial-quot: [ <flag> ] } ;

: local-server ( port -- addrspec ) "localhost" swap <inet> ;

: internet-server ( port -- addrspec ) f swap <inet> ;

: new-threaded-server ( encoding class -- threaded-server )
    new
        swap >>encoding ;

: <threaded-server> ( encoding -- threaded-server )
    threaded-server new-threaded-server ;

GENERIC: handle-client* ( threaded-server -- )

<PRIVATE

: >insecure ( addrspec -- addrspec' )
    dup { [ integer? ] [ string? ] } 1|| [ internet-server ] when ;

: >secure ( addrspec -- addrspec' )
    >insecure
    dup { [ secure? ] [ not ] } 1|| [ <secure> ] unless ;

: listen-on ( threaded-server -- addrspecs )
    [ secure>> >secure ] [ insecure>> >insecure ] bi
    [ resolve-host ] bi@ append ;

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

\ handle-client ERROR add-error-logging

: thread-name ( server-name addrspec -- string )
    unparse-short " connection from " glue ;

: accept-connection ( threaded-server -- )
    [ accept ] [ addr>> ] bi
    [ '[ _ _ _ handle-client ] ]
    [ drop threaded-server get name>> swap thread-name ] 2bi
    spawn drop ;

: accept-loop ( threaded-server -- )
    [
        threaded-server get semaphore>>
        [ [ accept-connection ] with-semaphore ]
        [ accept-connection ]
        if*
    ] [ accept-loop ] bi ; inline recursive

: started-accept-loop ( threaded-server -- )
    threaded-server get
    [ sockets>> push ] [ ready>> raise-flag ] bi ;

: start-accept-loop ( addrspec -- )
    threaded-server get encoding>> <server>
    [ started-accept-loop ] [ [ accept-loop ] with-disposal ] bi ;

\ start-accept-loop NOTICE add-error-logging

: init-server ( threaded-server -- threaded-server )
    dup semaphore>> [
        dup max-connections>> [
            <semaphore> >>semaphore
        ] when*
    ] unless ;

: (start-server) ( threaded-server -- )
    init-server
    dup threaded-server [
        [ ] [ name>> ] bi [
            [ listen-on [ start-accept-loop ] parallel-each ]
            [ ready>> raise-flag ]
            bi
        ] with-logging
    ] with-variable ;

PRIVATE>

: start-server ( threaded-server -- )
    #! Only create a secure-context if we want to listen on
    #! a secure port, otherwise start-server won't work at
    #! all if SSL is not available.
    dup secure>> [
        dup secure-config>> [
            (start-server)
        ] with-secure-context
    ] [
        (start-server)
    ] if ;

: wait-for-server ( threaded-server -- )
    ready>> wait-for-flag ;

: start-server* ( threaded-server -- )
    [ [ start-server ] curry "Threaded server" spawn drop ]
    [ wait-for-server ]
    bi ;

: stop-server ( threaded-server -- )
    [ f ] change-sockets drop dispose-each ;

: stop-this-server ( -- )
    threaded-server get stop-server ;

GENERIC: port ( addrspec -- n )

M: integer port ;

M: object port port>> ;

: secure-port ( -- n )
    threaded-server get dup [ secure>> port ] when ;

: insecure-port ( -- n )
    threaded-server get dup [ insecure>> port ] when ;
