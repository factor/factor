USING: tools.test io.files io io.streams.c
io.encodings.ascii strings ;
IN: io.streams.c.tests

[ "hello world" ] [
    "test.txt" temp-file ascii [
        "hello world" write
    ] with-file-writer

    "test.txt" temp-file "rb" fopen <c-reader> contents
    >string
] unit-test
