USING: tools.test io.files io io.streams.c io.encodings.ascii ;
IN: temporary

[ "hello world" ] [
    "test.txt" resource-path ascii [
        "hello world" write
    ] with-file-writer

    "test.txt" resource-path "rb" fopen <c-reader> contents
] unit-test
