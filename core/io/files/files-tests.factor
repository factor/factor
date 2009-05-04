USING: arrays debugger.threads destructors io io.directories
io.encodings.8-bit io.encodings.ascii io.encodings.binary
io.files io.files.private io.files.temp io.files.unique kernel
make math sequences system threads tools.test generic.single ;
IN: io.files.tests

[ ] [ "append-test" temp-file dup exists? [ delete-file ] [ drop ] if ] unit-test

[ ] [ "append-test" temp-file ascii <file-appender> dispose ] unit-test

[
    "This is a line.\rThis is another line.\r"
] [
    "vocab:io/test/mac-os-eol.txt" latin1
    [ 500 read ] with-file-reader
] unit-test

[
    255
] [
    "vocab:io/test/binary.txt" latin1
    [ read1 ] with-file-reader >fixnum
] unit-test

[ ] [
    "It seems Jobs has lost his grasp on reality again.\n"
    "separator-test.txt" temp-file latin1 set-file-contents
] unit-test

[
    {
        { "It seems " CHAR: J }
        { "obs has lost h" CHAR: i }
        { "s grasp on reality again.\n" f }
    }
] [
    [
        "separator-test.txt" temp-file
        latin1 [
            "J" read-until 2array ,
            "i" read-until 2array ,
            "X" read-until 2array ,
        ] with-file-reader
    ] { } make
] unit-test

[ ] [
    image binary [
        10 [ 65536 read drop ] times
    ] with-file-reader
] unit-test

! Test EOF behavior
[ 10 ] [
    image binary [
        0 read drop
        10 read length
    ] with-file-reader
] unit-test

USE: debugger.threads

[ ] [ "test-quux.txt" temp-file ascii [ [ yield "Hi" write ] "Test" spawn drop ] with-file-writer ] unit-test

[ ] [ "test-quux.txt" temp-file delete-file ] unit-test

[ ] [ "test-quux.txt" temp-file ascii [ [ yield "Hi" write ] "Test" spawn drop ] with-file-writer ] unit-test

[ ] [ "test-quux.txt" "quux-test.txt" [ temp-file ] bi@ move-file ] unit-test

[ t ] [ "quux-test.txt" temp-file exists? ] unit-test

[ ] [ "quux-test.txt" temp-file delete-file ] unit-test

! File seeking tests
[ B{ 3 2 3 4 5 } ]
[
    "seek-test1" unique-file binary
    [
        [
            B{ 1 2 3 4 5 } write 0 seek-absolute seek-output
            B{ 3 } write
        ] with-file-writer
    ] [
        file-contents
    ] 2bi
] unit-test

[ B{ 1 2 3 4 3 } ]
[
    "seek-test2" unique-file binary
    [
        [
            B{ 1 2 3 4 5 } write -1 seek-relative seek-output
            B{ 3 } write
        ] with-file-writer
    ] [
        file-contents
    ] 2bi
] unit-test

[ B{ 1 2 3 4 5 0 3 } ]
[
    "seek-test3" unique-file binary
    [
        [
            B{ 1 2 3 4 5 } write 1 seek-relative seek-output
            B{ 3 } write
        ] with-file-writer
    ] [
        file-contents
    ] 2bi
] unit-test

[ B{ 3 } ]
[
    B{ 1 2 3 4 5 } "seek-test4" unique-file binary [
        set-file-contents
    ] [
        [
            -3 seek-end seek-input 1 read
        ] with-file-reader
    ] 2bi
] unit-test

[ B{ 2 } ]
[
    B{ 1 2 3 4 5 } "seek-test5" unique-file binary [
        set-file-contents
    ] [
        [
            3 seek-absolute seek-input
            -2 seek-relative seek-input
            1 read
        ] with-file-reader
    ] 2bi
] unit-test

[
    "seek-test6" unique-file binary [
        -10 seek-absolute seek-input
    ] with-file-reader
] must-fail

[
    "non-string-error" unique-file ascii [
        { } write
    ] with-file-writer
] [ no-method? ] must-fail-with

[
    "non-byte-array-error" unique-file binary [
        "" write
    ] with-file-writer
] [ no-method? ] must-fail-with