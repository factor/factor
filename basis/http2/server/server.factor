USING: accessors http http.server io io.servers io.streams.peek
io.sockets kernel namespaces ;

IN: http2.server

! individual connection stuff
TUPLE: http2-stream ; ! do I even need this?

TUPLE: http2-connection streams settings hpack-decode-context
hpack-encode-context ;

CONSTANT: client-connection-prefix B{ 0x50 0x52 0x49 0x20 0x2a
            0x20 0x48 0x54 0x54 0x50 0x2f 0x32 0x2e 0x30 0x0d
            0x0a 0x0d 0x0a 0x53 0x4d 0x0d 0x0a 0x0d 0x0a } 

: start-http2-connection ( threaded-server prev-req/f -- )
    2drop
    ! TODO: establish http2 connection and carry out requests
    ! send settings frame.
    ! listen for connection prefix and settings from client.
    ! save settings and send ack.
    ;

! the server stuff
TUPLE: http2-server < http-server ;

! stack effect: ( threaded-server -- )
M: http2-server handle-client*
    ! check if this is a secure connection or not
    secure-addr dup port>> local-address get port>> = and
    [ t ! get tls(1.2?) negotiated thing
      [ f start-http2-connection ] ! if h2, send prefix and start full http2
      [ call-next-method ] ! else, revert to http1?
      if ] ! secure case
    [ ! first, check if the thing sent is connection prefix, and
      ! if so, start connection
      24 peek client-connection-prefix =
      [ f start-http2-connection ]
      [ f ! read initial request as http1
        t ! check if it asks for upgrade
        [ start-http2-connection ] ! if so, send 101 switching protocols response, start http2,
            ! including sending prefix and response to initial request.
        [ 
            ?refresh-all
            request-limit get limited-input
            [ read-request ] ?benchmark 
            [ do-request ] ?benchmark 
            [ do-response ] ?benchmark 
          [ handle-client-error ] recover ! else, finish processing as http1.
        ]
        if ]
      if ] ! insecure case
    if
    ;

