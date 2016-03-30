USING: alien.c-types alien.data io io.encodings.ascii io.files
io.files.temp io.files.unique io.streams.c kernel locals math
specialized-arrays strings tools.test ;
SPECIALIZED-ARRAY: int
IN: io.streams.c.tests

[
    "io-streams-c-tests-hello-world" ".txt" [| path |
        { "hello world" } [
            "hello world" path ascii set-file-contents

            path "rb" fopen <c-reader> stream-contents >string
        ] unit-test
    ] cleanup-unique-file

    ! Writing specialized arrays to binary streams
    "io-streams-c-tests-int" ".txt" [| path |
        { } [
            path "wb" fopen <c-writer> [
                int-array{ 1 2 3 } write
            ] with-output-stream
        ] unit-test

        { int-array{ 1 2 3 } } [
            path "rb" fopen <c-reader> [
                3 4 * read
            ] with-input-stream
            int cast-array
        ] unit-test
    ] cleanup-unique-file

    ! Writing strings to binary streams should fail
    "test-omgfail" ".txt" [| path |
        [
            path "wb" fopen <c-writer> [
                "OMGFAIL" write
            ] with-output-stream
        ] must-fail
    ] cleanup-unique-file

] with-temp-directory

