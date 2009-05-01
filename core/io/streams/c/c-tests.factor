USING: tools.test io.files io.files.temp io io.streams.c
io.encodings.ascii strings ;
IN: io.streams.c.tests

[ "hello world" ] [
    "hello world" "test.txt" temp-file ascii set-file-contents

    "test.txt" temp-file "rb" fopen <c-reader> stream-contents
    >string
] unit-test
