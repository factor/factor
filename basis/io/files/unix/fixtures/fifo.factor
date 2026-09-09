USING: accessors destructors io io.encodings.binary io.files io.pathnames
kernel libc locals tools.test unix unix.ffi ;
FROM: io => write ;

[
    "pipe" normalize-path 0o600 make-fifo
    { f } [ "pipe" binary [ read1 ] with-file-reader ] unit-test
    [ "pipe" binary <file-writer> dispose ]
    [ errno>> ENXIO = ] must-fail-with
    { B{ 1 2 3 } } [
        "pipe" binary <file-reader> [| reader |
            "pipe" binary [ B{ 1 2 3 } write ] with-file-writer
            3 reader stream-read
        ] with-disposal
    ] unit-test
] with-test-directory
