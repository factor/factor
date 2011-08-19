USING: accessors debugger kernel listener io.servers
io.encodings.utf8 namespaces ;

IN: tty-server

: start-listener ( -- )
    [ [ drop print-error-and-restarts ] error-hook set listener ] with-scope ;

: <tty-server> ( port -- server )
    utf8 <threaded-server>
        "tty-server" >>name
        swap local-server >>insecure
        [ start-listener ] >>handler
        f >>timeout ;

: run-tty-server ( -- )
    9999 <tty-server> start-server drop ;

MAIN: run-tty-server
