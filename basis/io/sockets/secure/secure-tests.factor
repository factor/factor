IN: io.sockets.secure.tests
USING: accessors io.sockets io.sockets.secure io.sockets.secure.debug
kernel system tools.test ;

{ "hello" 24 } [ "hello" 24 <inet> "hello" <secure> [ host>> ] [ port>> ] bi ] unit-test

{ } [
    <test-secure-config> [ ] with-secure-context
] unit-test

{ t } [ os windows? ssl-certificate-verification-supported? or ] unit-test
