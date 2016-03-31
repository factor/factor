USING: alien alien.c-types alien.data arrays classes.struct
compiler.units continuations destructors generic.single io
io.directories io.encodings.8-bit.latin1 io.encodings.ascii
io.encodings.binary io.encodings.string io.files
io.files.private io.files.temp io.files.unique io.pathnames
kernel locals make math sequences specialized-arrays
system threads tools.test vocabs ;
FROM: specialized-arrays.private => specialized-array-vocab ;
IN: io.files.tests

SPECIALIZED-ARRAY: int

{ } [
    [
        "append-test" ".txt" [| path |
            path ascii <file-appender> dispose
        ] cleanup-unique-file
    ] with-temp-directory
] unit-test

{
    "This is a line.\rThis is another line.\r"
} [
    "vocab:io/test/mac-os-eol.txt" latin1
    [ 500 read ] with-file-reader
] unit-test

{
    255
} [
    "vocab:io/test/binary.txt" latin1
    [ read1 ] with-file-reader >fixnum
] unit-test

{
    "This" CHAR: \s
} [
    "vocab:io/test/read-until-test.txt" ascii
    [ " " read-until ] with-file-reader
] unit-test

{
    "This" CHAR: \s
} [
    "vocab:io/test/read-until-test.txt" binary
    [ " " read-until [ ascii decode ] dip ] with-file-reader
] unit-test

[
    "separator-test" ".txt" [| path |
        { } [
            "It seems Jobs has lost his grasp on reality again.\n"
            path latin1 set-file-contents
        ] unit-test

        {
            {
                { "It seems " CHAR: J }
                { "obs has lost h" CHAR: i }
                { "s grasp on reality again.\n" f }
            }
        } [
            [
                path latin1 [
                    "J" read-until 2array ,
                    "i" read-until 2array ,
                    "X" read-until 2array ,
                ] with-file-reader
            ] { } make
        ] unit-test
    ] cleanup-unique-file
] with-temp-directory

{ } [
    image-path binary [
        10 [ 65536 read drop ] times
    ] with-file-reader
] unit-test

! Writing specialized arrays to binary streams should work
[
    "binary-int-array" ".bin" [| path |
        { } [
            path binary [
                int-array{ 1 2 3 } write
            ] with-file-writer
        ] unit-test

        { int-array{ 1 2 3 } } [
            path binary [
                3 4 * read
            ] with-file-reader
            int cast-array
        ] unit-test
    ] cleanup-unique-file
] with-temp-directory

[
    "test-012" ".bin" [| path |
        { } [
            BV{ 0 1 2 } path binary set-file-contents
        ] unit-test

        { t } [
            path binary file-contents
            B{ 0 1 2 } =
        ] unit-test
    ] cleanup-unique-file
] with-temp-directory

STRUCT: pt { x uint } { y uint } ;
SPECIALIZED-ARRAY: pt

CONSTANT: pt-array-1
    pt-array{ S{ pt f 1 1 } S{ pt f 2 2 } S{ pt f 3 3 } }

[
    "test-pt-array-1" ".bin" [| path |
        { } [
            pt-array-1 path binary set-file-contents
        ] unit-test

        { t } [
            path binary file-contents
            pt-array-1 >c-ptr sequence=
        ] unit-test
    ] cleanup-unique-file
] with-temp-directory

! Slices should support >c-ptr and byte-length
[
    "test-pt-array-1-slice" ".bin" [| path |
        { } [
            pt-array-1 rest-slice
            path binary set-file-contents
        ] unit-test
    
        { t } [
            path binary file-contents
            pt cast-array
            pt-array-1 rest-slice sequence=
        ] unit-test
    ] cleanup-unique-file
] with-temp-directory

{ } [
    [
        pt specialized-array-vocab forget-vocab
    ] with-compilation-unit
] unit-test

! Writing strings to binary streams should fail
[
    "omgfail-binary" ".bin" [| path |
        path binary [ "OMGFAIL" write ] with-file-writer
    ] cleanup-unique-file
] must-fail

! Test EOF behavior
{ 10 } [
    image-path binary [
        0 read drop
        10 read length
    ] with-file-reader
] unit-test

! Make sure that writing to a closed stream from another thread doesn't crash
! Don't use cleanup-unique-file here because we do manual cleanup as part of test
[
    "test-quux" ".txt" unique-file [| path |
        path ".2" append :> path2

        { } [ path ascii [ [ yield "Hi" write ] "Test-write-file" spawn drop ] with-file-writer ] unit-test

        { } [ path delete-file ] unit-test

        { } [ path ascii [ [ yield "Hi" write ] "Test-write-file" spawn drop ] with-file-writer ] unit-test

        { } [ path path2 move-file ] unit-test

        { t } [ path2 exists? ] unit-test

        { } [ path2 delete-file ] unit-test
    ] call
] with-temp-directory

! File seeking tests
{ B{ 3 2 3 4 5 } }
[
    [
        "seek-test1" "" [
            binary
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
        ] cleanup-unique-file
    ] with-temp-directory
] unit-test

{ B{ 1 2 3 4 3 } }
[
    [
        "seek-test2" "" [
        binary
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
        ] cleanup-unique-file
    ] with-temp-directory
] unit-test

{ B{ 1 2 3 4 5 0 3 } }
[
    [
        "seek-test3" "" [
            binary
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
        ] cleanup-unique-file
    ] with-temp-directory
] unit-test

{ B{ 3 } }
[
    [
        "seek-test4" "" [
            B{ 1 2 3 4 5 } swap binary
            [
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
        ] cleanup-unique-file
    ] with-temp-directory
] unit-test

{ B{ 2 } }
[
    [
        "seek-test5" "" [
            B{ 1 2 3 4 5 } swap binary [
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
        ] cleanup-unique-file
    ] with-temp-directory
] unit-test

[
    [
        "seek-test6" "" [
            binary [
                -10 seek-absolute seek-input
            ] with-file-reader
        ] cleanup-unique-file
    ] with-temp-directory
] must-fail

{ } [
    "resource:LICENSE.txt" binary [
        44 read drop
        tell-input 44 assert=
        -44 seek-relative seek-input
        tell-input 0 assert=
    ] with-file-reader
] unit-test

[
    [
        "non-string-error" "" [
            ascii [ { } write ] with-file-writer
        ] cleanup-unique-file
    ] with-temp-directory
] [ no-method? ] must-fail-with

[
    [
        "non-byte-array-error" "" [
            binary [ "" write ] with-file-writer
        ] cleanup-unique-file
    ] with-temp-directory
] [ no-method? ] must-fail-with

! What happens if we close a file twice?
{ } [
    [
        "closing-twice" "" [
            ascii <file-writer>
            [ dispose ] [ dispose ] bi
        ] cleanup-unique-file
    ] with-temp-directory
] unit-test

! Test cwd, cd.
! NOTE TO USER: You do not want to use with-cd, you want with-directory.
: with-cd ( path quot -- )
    [ [ absolute-path cd ] curry ] dip compose
    cwd [ cd ] curry
    [ ] cleanup ; inline

{ t } [
    cwd
    "resource:core/" [ "hi" print ] with-cd
    cwd =
] unit-test

{ t } [
    cwd
    [ "resource:core/" [ "nick cage" throw ] with-cd ] [ drop ] recover
    cwd =
] unit-test

[
    "resource:core/" [ "nick cage" throw ] with-cd
] [ "nick cage" = ] must-fail-with
