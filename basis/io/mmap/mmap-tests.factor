USING: io io.mmap io.mmap.char io.files io.files.temp
io.directories kernel tools.test continuations sequences
io.encodings.ascii accessors ;
IN: io.mmap.tests

[ "mmap-test-file.txt" temp-file delete-file ] ignore-errors
[ ] [ "12345" "mmap-test-file.txt" temp-file ascii set-file-contents ] unit-test
[ ] [ "mmap-test-file.txt" temp-file [ CHAR: 2 0 pick set-nth drop ] with-mapped-char-file ] unit-test
[ 5 ] [ "mmap-test-file.txt" temp-file [ length ] with-mapped-char-file ] unit-test
[ "22345" ] [ "mmap-test-file.txt" temp-file ascii file-contents ] unit-test
[ "mmap-test-file.txt" temp-file delete-file ] ignore-errors


[ ]
[ "mmap-empty-file.txt" temp-file touch-file ] unit-test

! Test for leaking resources bug on Unix
[ ]
[
    100000 [
        [
            "mmap-empty-file.txt" temp-file [
                drop
            ] with-mapped-file
        ] [ dup bad-mmap-size? [ drop ] [ rethrow ] if ] recover
    ] times

    "asdf" "mmap-asdf-file.txt" temp-file [ ascii set-file-contents ] keep [
        drop
    ] with-mapped-file
] unit-test
