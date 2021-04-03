USING: accessors http http.server io.servers io.sockets kernel
namespaces ;

IN: http2.server

TUPLE: http2-server < http-server ;

: start-http2-connection ( threaded-server prev-req/f -- )
    2drop
    ! TODO: establish http2 connection and carry out requests
    ;

! stack effect: ( threaded-server -- )
M: http2-server handle-client*
    secure-addr dup port>> local-address get port>> = and ! check if this is a secure connection or not
    [ t ! get tls(1.2?) negotiated thing
      [ f start-http2-connection ] ! if h2, send prefix and start full http2
      [ call-next-method ] ! else, revert to http1?
      if ] ! secure case
    [ f ! read initial request as http1
      t ! check if it asks for upgrade
      [ start-http2-connection ] ! if so, send 101 switching protocols response, start http2,
          ! including sending prefix and response to initial request.
      [ 2drop ] ! else, finish processing as http1.
      if ] ! insecure case
    if
    ;

