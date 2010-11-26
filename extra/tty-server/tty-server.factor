USING: listener io.servers io.encodings.utf8 accessors kernel ;
IN: tty-server

: <tty-server> ( port -- )
    utf8 <threaded-server>
        "tty-server" >>name
        swap local-server >>insecure
        [ listener ] >>handler
    start-server drop ;

: tty-server ( -- ) 9999 <tty-server> ;

MAIN: tty-server
