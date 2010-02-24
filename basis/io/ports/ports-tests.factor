USING: destructors io io.encodings.binary io.files io.directories
io.files.temp io.ports kernel sequences math
specialized-arrays.instances.alien.c-types.int tools.test
specialized-arrays alien.c-types classes.struct alien ;
IN: io.ports.tests

! Make sure that writing malloced storage to a file works, and
! also make sure that writes larger than the buffer size work

[ ] [
    "test.txt" temp-file binary [
        100,000 iota
        0
        100,000 malloc-int-array &dispose [ copy ] keep write
    ] with-file-writer
] unit-test

[ t ] [
    "test.txt" temp-file binary [
        100,000 4 * read byte-array>int-array 100,000 iota sequence=
    ] with-file-reader
] unit-test

USE: multiline
/*
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

[ ] [
    pt-array-1 rest-slice 
    "test.txt" temp-file binary set-file-contents
] unit-test

[ t ] [
    "test.txt" temp-file binary file-contents
    pt-array-1 rest-slice >c-ptr sequence=
] unit-test

*/

[ ] [ "test.txt" temp-file delete-file ] unit-test
