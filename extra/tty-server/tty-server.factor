USING: listener io.servers.connection io.encodings.utf8
accessors kernel ;
IN: tty-server

: <tty-server> ( port -- )
    <threaded-server>
        "tty-server" >>name
        utf8 >>encoding
        swap local-server >>insecure
        [ listener ] >>handler
    start-server ;

: tty-server ( -- ) 9999 <tty-server> ;

MAIN: tty-server
