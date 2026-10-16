USING: accessors io.sockets io.sockets.private
kernel sequences tools.test unix.ffi ;
IN: io.sockets.unix.android.tests

{ 0 } [ "/factor-socket" <local> make-sockaddr path>> first ] unit-test

{ t } [
    "/factor-socket" <local>
    [ dup make-sockaddr ] keep parse-sockaddr =
] unit-test
