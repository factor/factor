USING: http.server kernel io.server ;

IN: http2.server

TUPLE: http2-server < threaded-server ;

! stack effect: ( -- )
M: http-server handle-client*
    ;

