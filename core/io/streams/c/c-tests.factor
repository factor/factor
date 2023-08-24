USING: alien alien.c-types alien.data debugger io io.encodings.ascii
io.files io.pathnames io.streams.c kernel math specialized-arrays
strings tools.test ;
SPECIALIZED-ARRAY: int

[
    ! Writing strings to ascii streams
    { "hello world" } [
        "hello-world.txt" absolute-path
        [ "hello world" swap ascii set-file-contents ]
        [ "rb" fopen <c-reader> stream-contents >string ] bi
    ] unit-test

    ! Writing specialized arrays to binary streams
    { int-array{ 1 2 3 } } [
        "c-tests-int.dat" absolute-path [
            "wb" fopen <c-writer> [
                int-array{ 1 2 3 } write
            ] with-output-stream
        ] [
            "rb" fopen <c-reader> [
                3 4 * read int cast-array
            ] with-input-stream
        ] bi
    ] unit-test

    ! Writing strings to binary streams should fail
    [
        "omgfail.txt" absolute-path "wb" fopen <c-writer> [
            "OMGFAIL" write
        ] with-output-stream
    ] must-fail

] with-test-directory


[ 3 10 99 <alien> fseek ] [ vm-error? ] must-fail-with
