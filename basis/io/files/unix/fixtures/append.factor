USING: destructors io io.encodings.ascii io.files locals tools.test ;

[
    { "ba" } [
        "append" ascii <file-appender> [| first |
            "append" ascii [ "b" write ] with-file-appender
            "a" first stream-write first stream-flush
        ] with-disposal
        "append" ascii file-contents
    ] unit-test
] with-test-directory
