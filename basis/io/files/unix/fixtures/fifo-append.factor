USING: destructors io io.backend.unix io.encodings.binary io.files io.pathnames
io.ports literals locals tools.test unix unix.ffi ;
FROM: io => write ;

[
    "pipe" normalize-path 0o600 make-fifo
    { B{ 4 5 6 } } [
        "pipe" normalize-path flags{ O_RDONLY O_NONBLOCK } 0 open-file
        <fd> init-fd <input-port> [| reader |
            "pipe" binary [ B{ 4 5 6 } write ] with-file-appender
            3 reader stream-read
        ] with-disposal
    ] unit-test
] with-test-directory
