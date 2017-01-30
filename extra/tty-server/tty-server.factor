USING: accessors command-line debugger io.encodings.utf8
io.servers kernel listener math.parser namespaces sequences ;

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
    command-line get [ 9999 ] [ first string>number ] if-empty
    <tty-server> start-server wait-for-server ;

MAIN: run-tty-server
