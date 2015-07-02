USING: alien.c-types alien.data compiler.tree.debugger
continuations io.directories io.encodings.ascii io.files
io.files.temp io.mmap kernel math sequences sequences.private
specialized-arrays tools.test ;
SPECIALIZED-ARRAY: uint
IN: io.mmap.tests

[ "mmap-test-file.txt" temp-file delete-file ] ignore-errors
[ ] [ "12345" "mmap-test-file.txt" temp-file ascii set-file-contents ] unit-test
[ ] [ "mmap-test-file.txt" temp-file [ char <mapped-array> CHAR: 2 0 pick set-nth drop ] with-mapped-file ] unit-test
[ 5 ] [ "mmap-test-file.txt" temp-file [ char <mapped-array> length ] with-mapped-file ] unit-test
[ 5 ] [ "mmap-test-file.txt" temp-file [ char <mapped-array> length ] with-mapped-file-reader ] unit-test
[ "22345" ] [ "mmap-test-file.txt" temp-file ascii file-contents ] unit-test

SPECIALIZED-ARRAY: uint

[ t ] [
    "mmap-test-file.txt" temp-file uint [ sum ] with-mapped-array
    integer?
] unit-test

[ t ] [
    "mmap-test-file.txt" temp-file uint [ sum ] with-mapped-array-reader
    integer?
] unit-test

[ "mmap-test-file.txt" temp-file delete-file ] ignore-errors


[ "mmap-empty-file.txt" temp-file delete-file ] ignore-errors
[ ] [ "mmap-empty-file.txt" temp-file touch-file ] unit-test

[
    "mmap-empty-file.txt" temp-file [
        drop
    ] with-mapped-file
] [ bad-mmap-size? ] must-fail-with

[ t ] [
    [ "test.txt" <mapped-file> void* <c-direct-array> first-unsafe ]
    { nth-unsafe } inlined?
] unit-test
