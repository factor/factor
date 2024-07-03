USING: accessors command-line continuations debugger
io.encodings.utf8 io.servers kernel listener listener.private
math.parser namespaces parser.notes sequences vocabs.parser ;

IN: tty-server.shared

: start-shared-listener ( manifest -- )
    [
        [ [ drop print-error-and-restarts ] error-hook set
        parser-quiet? off
        [ { } listener-loop ] with-return ] with-scope
    ] swap (with-manifest) ;

: <shared-tty-server> ( port -- server )
    utf8 <threaded-server>
        "tty-server" >>name
        swap local-server >>insecure
        [ manifest get ] with-interactive-vocabs
        '[ _ start-shared-listener ] >>handler
        f >>timeout ;

: run-shared-tty-server ( -- )
    command-line get [ 9999 ] [ first string>number ] if-empty
    <shared-tty-server> start-server wait-for-server ;

MAIN: run-shared-tty-server
