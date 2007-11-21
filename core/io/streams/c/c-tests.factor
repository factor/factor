USING: tools.test io.files io io.streams.c ;
IN: temporary

[ "hello world" ] [
    "test.txt" resource-path <file-writer> [
        "hello world" write
    ] with-stream

    "test.txt" resource-path "rb" fopen <c-reader> contents
] unit-test
