USING: io.sockets.secure io.encodings.ascii alien.strings
openssl namespaces accessors tools.test continuations kernel ;

openssl ssl-backend [
    [ ] [
        <ssl-config>
            "resource:extra/openssl/test/server.pem" >>key-file
            "resource:extra/openssl/test/root.pem" >>ca-file
            "resource:extra/openssl/test/dh1024.pem" >>dh-file
            "password" ascii string>alien >>password
        [ ] with-ssl-context
    ] unit-test

    [
        <ssl-config>
            "resource:extra/openssl/test/server.pem" >>key-file
            "resource:extra/openssl/test/root.pem" >>ca-file
            "wrong password" ascii string>alien >>password
        [ ] with-ssl-context
    ] must-fail
] with-variable
