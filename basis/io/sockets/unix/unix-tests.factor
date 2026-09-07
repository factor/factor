USING: accessors destructors io.encodings.binary io.sockets kernel
tools.test ;
IN: io.sockets.unix

[
    ! Ask the OS for an ephemeral port, then close the listener before
    ! connecting. A fixed port could already have a service listening.
    "127.0.0.1" 0 <inet4> binary <server>
    [ addr>> ] with-disposal
    binary [ ] with-client
] [
    message>> "Connection refused" =
] must-fail-with
