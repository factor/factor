USING: tools.test io.files io io.streams.c ;
IN: temporary

[ "hello world" ] [
    "test.txt" resource-path ascii [
        "hello world" write
    ] with-file-writer

    "test.txt" resource-path "rb" fopen <c-reader> contents
] unit-test
