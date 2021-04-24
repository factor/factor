USING: accessors continuations http http.server http.server.requests
io io.encodings.ascii io.servers io.sockets io.streams.peek
io.streams.limited kernel namespaces openssl.libssl ; 

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
    ?refresh-all
    request-limit get limited-input
    secure-addr dup port>> local-address get port>> = and
    [ t ! get tls(1.2?) negotiated thing: replace with get_alpn_selected
      [ f start-http2-connection ] ! if h2, send prefix and start full http2
      [ call-next-method ] ! else, revert to http1?
      if ] ! secure case
    [ ! first, check if the thing sent is connection prefix, and
      ! if so, start connection
      24 peek client-connection-prefix =
      [ f start-http2-connection ]
      [ 
        [
          [ read-request ] ?benchmark 
          dup "Upgrade" header 
          "h2c" =
          [ start-http2-connection ] ! if so, send 101 switching protocols response, start http2,
          ! including sending prefix and response to initial request.
          [ 
            ! else, finish processing as http1.
            nip
            [ do-request ] ?benchmark 
            [ do-response ] ?benchmark 
          ] if 
        ]
        [ nip handle-client-error ] recover 
        ]
      if ] ! insecure case
    if
    ;

: <http2-server> ( -- server )
    ascii http2-server new-threaded-server
        "http2.server" >>name
        "http" protocol-port >>insecure
        "https" protocol-port >>secure ;

