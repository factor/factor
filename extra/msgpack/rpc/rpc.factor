USING: msgpack kernel accessors assocs arrays sequences
combinators make io threads destructors concurrency.locks
io.streams.duplex math.parser ;

IN: msgpack.rpc

TUPLE: request msgid method params ;

TUPLE: response msgid error result ;

TUPLE: notification method params ;

TUPLE: session active? incoming-requests outgoing-requests notification-callback request-callback ;

M: request write-msgpack
    0 swap [ msgid>> ] [ method>> ] [ params>> ]
    tri 4array write-msgpack ;

M: response write-msgpack
    1 swap [ msgid>> ] [ error>> ] [ result>> ]
    tri 4array write-msgpack ;

M: notification write-msgpack
    2 swap [ method>> ] [ params>> ]
    bi 3array write-msgpack ;

GENERIC: feed-packet ( session packet -- )
GENERIC: stop ( session -- )

! TODO close active requests
M: session stop ( session -- )
    f swap active?<< ;

: <session> ( -- session )
    t H{ } clone H{ } clone [ drop ] [ drop ] session boa ;

C: <request> request

: <notification> ( method params -- notification )
    notification boa ;

:: <response-ok> ( id result -- response )
    id +msgpack-nil+ result response boa ;

: <response-error> ( id error -- response )
    +msgpack-nil+ response boa ;

ERROR: invalid-packet packet ;

ERROR: id-present id ;

<PRIVATE

M: notification feed-packet
    swap notification-callback>> call( notification -- ) ;

: check-array ( obj -- obj )
    dup array? [ ] [ invalid-packet ] if ;

: make-request ( arr -- request )
    rest first3 request boa ;

: make-response ( arr -- response )
    rest first3 response boa ;

: make-notification ( arr -- notification )
    rest first2 notification boa ;

: parse-packet ( msgpack -- packet )
    check-array dup first {
        { 0 [ make-request ] }
        { 1 [ make-response ] }
        { 2 [ make-notification ] }
        [ drop invalid-packet ]
    } case ;

: ?read-packet ( -- packet/f )
    ?read-msgpack [ parse-packet ] [  ] if ;

: check-request-id-absent ( request requests -- )
    [ msgid>> ] dip dupd key?
    [ id-present ] [ drop ] if ;

M:: request feed-packet ( session request -- )
    request msgid>> :> id
    session incoming-requests>> :> requests
    request requests check-request-id-absent
    request id requests set-at
    request session request-callback>>
    call( request -- ) ;

:: feed-request ( session request quot: ( response -- .. ) -- )
    session outgoing-requests>> :> requests
    request requests check-request-id-absent
    quot request msgid>> requests set-at ;

PRIVATE>

ERROR: unknown-response response ;

:: feed-response ( session response -- )
    response msgid>> session incoming-requests>> delete-at* nip
    [ response unknown-response ] unless ;

M: response feed-packet ( session response -- )
    swap dupd
    [ msgid>> ] [ outgoing-requests>> ] bi* delete-at*
    [ call( response --  ) ] [ unknown-response ] if ;

! the output lock makes sure that when we send
! requests/notification from different threads, we never
! interleave writing the packets
! no such lock is needed for reading, because all reads are from
! one thread
TUPLE: connection stream session thread output-lock name ;

: <connection> ( stream -- connection )
    <session> f <lock>
    "msgpack.rpc default name" connection boa ;

M: connection stop ( steam-session -- )
    [ session>> stop ] [ stream>> dispose ] bi ;

<PRIVATE

:: recv-packet ( connection -- ? )
    connection stream>> :> stream
    connection session>> :> session
    stream [ ?read-packet ] with-stream* dup
    '[ session _ feed-packet t ] [ connection stop f ] if ;

: send-packet ( obj connection -- )
    dup output-lock>>
    [ stream>> [ write-msgpack flush ] with-stream* ]
    with-lock ;

:: recv-loop ( connection --  )
    [ connection recv-packet ] loop
    connection stop ;

PRIVATE>

:: start ( connection -- )
    [ connection recv-loop ] connection name>> spawn
    connection thread<< ;

: send-notification ( notification connection -- )
    send-packet ;

:: send-response ( response connection -- )
    connection session>> response feed-response
    response connection send-packet ;

:: send-request ( ... request quot: ( ... response -- ... ) connection -- ... )
    connection session>> request quot feed-request
    request connection send-packet ;

<PRIVATE

: request-thread-name ( request -- name )
    [ method>> ] [ msgid>> number>string ] bi
    '[ _ , "-" , _ , ] { } make concat ;

PRIVATE>

:: send-request-await ( request connection -- response )
    self [ resume-with ] curry
    '[ request _ connection send-request ] call
    request request-thread-name suspend ;
