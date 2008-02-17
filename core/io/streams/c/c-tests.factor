USING: tools.test io.files io io.streams.c ;
IN: temporary

[ "hello world" ] [
    "test.txt" resource-path [
        "hello world" write
    ] with-file-writer

    "test.txt" resource-path "rb" fopen <c-reader> contents
] unit-test
