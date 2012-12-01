USING: alien alien.c-types alien.data arrays classes.struct
debugger.threads destructors generic.single io io.directories
io.encodings.8-bit.latin1 io.encodings.ascii
io.encodings.binary io.encodings.string io.files
io.files.private io.files.temp io.files.unique kernel make math
sequences specialized-arrays system threads tools.test vocabs
compiler.units ;
FROM: specialized-arrays.private => specialized-array-vocab ;
SPECIALIZED-ARRAY: int
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

[
    "This" CHAR: \s
] [
    "vocab:io/test/read-until-test.txt" ascii
    [ " " read-until ] with-file-reader
] unit-test

[
    "This" CHAR: \s
] [
    "vocab:io/test/read-until-test.txt" binary
    [ " " read-until [ ascii decode ] dip ] with-file-reader
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

! Writing specialized arrays to binary streams should work
[ ] [
    "test.txt" temp-file binary [
        int-array{ 1 2 3 } write
    ] with-file-writer
] unit-test

[ int-array{ 1 2 3 } ] [
    "test.txt" temp-file binary [
        3 4 * read
    ] with-file-reader
    int cast-array
] unit-test

[ ] [
    BV{ 0 1 2 } "test.txt" temp-file binary set-file-contents
] unit-test

[ t ] [
    "test.txt" temp-file binary file-contents
    B{ 0 1 2 } =
] unit-test

STRUCT: pt { x uint } { y uint } ;
SPECIALIZED-ARRAY: pt

CONSTANT: pt-array-1
    pt-array{ S{ pt f 1 1 } S{ pt f 2 2 } S{ pt f 3 3 } }

[ ] [
    pt-array-1
    "test.txt" temp-file binary set-file-contents
] unit-test

[ t ] [
    "test.txt" temp-file binary file-contents
    pt-array-1 >c-ptr sequence=
] unit-test

! Slices should support >c-ptr and byte-length

[ ] [
    pt-array-1 rest-slice
    "test.txt" temp-file binary set-file-contents
] unit-test

[ t ] [
    "test.txt" temp-file binary file-contents
    pt cast-array
    pt-array-1 rest-slice sequence=
] unit-test

[ ] [
    [
        pt specialized-array-vocab forget-vocab
    ] with-compilation-unit
] unit-test

! Writing strings to binary streams should fail
[
    "test.txt" temp-file binary [
        "OMGFAIL" write
    ] with-file-writer
] must-fail

! Test EOF behavior
[ 10 ] [
    image binary [
        0 read drop
        10 read length
    ] with-file-reader
] unit-test

! Make sure that writing to a closed stream from another thread doesn't crash
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
            B{ 1 2 3 4 5 } write
            tell-output 5 assert=
            0 seek-absolute seek-output
            tell-output 0 assert=
            B{ 3 } write
            tell-output 1 assert=
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
            B{ 1 2 3 4 5 } write
            tell-output 5 assert=
            -1 seek-relative seek-output
            tell-output 4 assert=
            B{ 3 } write
            tell-output 5 assert=
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
            B{ 1 2 3 4 5 } write
            tell-output 5 assert=
            1 seek-relative seek-output
            tell-output 6 assert=
            B{ 3 } write
            tell-output 7 assert=
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
            tell-input 0 assert=
            -3 seek-end seek-input
            tell-input 2 assert=
            1 read
            tell-input 3 assert=
        ] with-file-reader
    ] 2bi
] unit-test

[ B{ 2 } ]
[
    B{ 1 2 3 4 5 } "seek-test5" unique-file binary [
        set-file-contents
    ] [
        [
            tell-input 0 assert=
            3 seek-absolute seek-input
            tell-input 3 assert=
            -2 seek-relative seek-input
            tell-input 1 assert=
            1 read
            tell-input 2 assert=
        ] with-file-reader
    ] 2bi
] unit-test

[
    "seek-test6" unique-file binary [
        -10 seek-absolute seek-input
    ] with-file-reader
] must-fail

[ ] [
    "resource:license.txt" binary [
        44 read drop
        tell-input 44 assert=
        -44 seek-relative seek-input
        tell-input 0 assert=
    ] with-file-reader
] unit-test

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

! What happens if we close a file twice?
[ ] [
    "closing-twice" unique-file ascii <file-writer>
    [ dispose ] [ dispose ] bi
] unit-test
