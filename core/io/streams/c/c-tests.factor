USING: tools.test io.files io.files.temp io io.streams.c
io.encodings.ascii strings destructors kernel specialized-arrays
alien.c-types math alien.data ;
SPECIALIZED-ARRAY: int
IN: io.streams.c.tests

[ "hello world" ] [
    "hello world" "test.txt" temp-file ascii set-file-contents

    "test.txt" temp-file "rb" fopen <c-reader> stream-contents
    >string
] unit-test

! Writing specialized arrays to binary streams
[ ] [
    "test.txt" temp-file "wb" fopen <c-writer> [
        int-array{ 1 2 3 } write
    ] with-output-stream
] unit-test

[ int-array{ 1 2 3 } ] [
    "test.txt" temp-file "rb" fopen <c-reader> [
        3 4 * read
    ] with-input-stream
    int cast-array
] unit-test

! Writing strings to binary streams should fail
[
    "test.txt" temp-file "wb" fopen <c-writer> [
        "OMGFAIL" write
    ] with-output-stream
] must-fail
