USING: arrays io io.files kernel math parser strings system
tools.test words namespaces make io.encodings.8-bit
io.encodings.binary sequences io.files.unique ;
IN: io.tests

[ f ] [
    "resource:core/io/test/no-trailing-eol.factor" run-file
    "foo" "io.tests" lookup
] unit-test

! Make sure we use correct to_c_string form when writing
[ ] [ "\0" write ] unit-test

[ B{ 3 2 3 4 5 } ]
[
    "seek-test1" unique-file binary
    [
        [
            B{ 1 2 3 4 5 } write flush 0 seek-absolute seek-output
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
            B{ 1 2 3 4 5 } write flush -1 seek-relative seek-output
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
            B{ 1 2 3 4 5 } write flush 1 seek-relative seek-output
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
