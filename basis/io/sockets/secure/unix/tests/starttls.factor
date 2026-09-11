USING: accessors alien.c-types alien.syntax calendar concurrency.futures
concurrency.promises destructors io io.encodings.ascii io.ports io.sockets
io.sockets.secure io.sockets.secure.debug io.streams.duplex kernel locals
namespaces openssl.libssl tools.test ;
IN: io.sockets.secure.unix.starttls-tests

LIBRARY: libssl
FUNCTION: c-string SSL_get_servername ( SSL* ssl, int type )

! A plain TCP connection upgraded to TLS must send the original DNS hostname.
{ "localhost" } [
  [let
    <promise> :> port
    [
        <test-secure-config> [
            "127.0.0.1" 0 <inet4> ascii <server> [
                dup addr>> port>> port fulfill
                accept drop [
                    accept-secure-handshake
                    "ready" print flush
                    output-stream get underlying-port handle>> handle>>
                    TLSEXT_NAMETYPE_host_name SSL_get_servername
                ] with-stream
            ] with-disposal
        ] with-secure-context
    ] future :> server
    <secure-config> f >>verify [
        "localhost" port 5 seconds ?promise-timeout <inet> ascii [
            send-secure-handshake readln "ready" assert=
        ] with-client
    ] with-secure-context
    server 5 seconds ?future-timeout
  ]
] unit-test
