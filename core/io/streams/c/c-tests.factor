USING: tools.test io.files io io.streams.c ;
IN: temporary

[ "hello world" ] [
    "test.txt" temp-file [
        "hello world" write
    ] with-file-writer

    "test.txt" temp-file "rb" fopen <c-reader> contents
] unit-test
