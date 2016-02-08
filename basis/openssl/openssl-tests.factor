USING: accessors io.sockets.secure io.sockets.secure.debug namespaces
openssl tools.test ;

openssl secure-socket-backend [
    { } [
        <test-secure-config>
        [ ] with-secure-context
    ] unit-test

    [
        <test-secure-config> "wrong password" >>password
        [ ] with-secure-context
    ] must-fail
] with-variable
