USING: accessors io.encodings.binary io.sockets kernel
tools.test ;
IN: io.sockets.unix

[
    T{ inet f "127.0.0.1" 5000 } binary [ ] with-client
] [
    message>> "Connection refused" =
] must-fail-with
