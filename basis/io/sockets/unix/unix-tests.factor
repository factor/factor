USING: accessors alien.strings destructors io.encodings.binary
io.encodings.utf8 io.pathnames io.sockets io.sockets.private kernel
math sequences strings tools.test unix.ffi ;
IN: io.sockets.unix

! sockaddr-un has a fixed-size byte array, including the terminating NUL.
{ t t } [
    "/factor-socket" <local> make-sockaddr path>>
    [ length max-un-path = ]
    [ utf8 alien>string "/factor-socket" = ] bi
] unit-test

{ t } [
    max-un-path 2 - CHAR: a <string> "/" prepend
    dup <local> make-sockaddr path>> utf8 alien>string =
] unit-test

[
    max-un-path 1 - CHAR: a <string> "/" prepend
    <local> make-sockaddr drop
] [ "Path too long" = ] must-fail-with

! Check the encoded byte length: a multibyte path can fit by character
! count while overflowing the native socket address field.
[
    max-un-path 2 /i CHAR: é <string> "/" prepend
    <local> make-sockaddr drop
] [ "Path too long" = ] must-fail-with

[
    ! Ask the OS for an ephemeral port, then close the listener before
    ! connecting. A fixed port could already have a service listening.
    "127.0.0.1" 0 <inet4> binary <server>
    [ addr>> ] with-disposal
    binary [ ] with-client
] [
    message>> "Connection refused" =
] must-fail-with
