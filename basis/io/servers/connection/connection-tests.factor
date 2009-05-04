IN: io.servers.connection
USING: tools.test io.servers.connection io.sockets namespaces
io.servers.connection.private kernel accessors sequences
concurrency.promises io.encodings.ascii io threads calendar ;

[ t ] [ <threaded-server> listen-on empty? ] unit-test

[ f ] [
    <threaded-server>
        25 internet-server >>insecure
    listen-on
    empty?
] unit-test

[ t ] [
    T{ inet4 f "1.2.3.4" 1234 } T{ inet4 f "1.2.3.5" 1235 }
    [ log-connection ] 2keep
    [ remote-address get = ] [ local-address get = ] bi*
    and
] unit-test

[ ] [ <threaded-server> init-server drop ] unit-test

[ 10 ] [
    <threaded-server>
        10 >>max-connections
    init-server semaphore>> count>> 
] unit-test

[ ] [
    <threaded-server>
        5 >>max-connections
        0 >>insecure
        [ "Hello world." write stop-this-server ] >>handler
    dup start-server* sockets>> first addr>> port>> "port" set
] unit-test

[ "Hello world." ] [ "localhost" "port" get <inet> ascii <client> drop stream-contents ] unit-test
