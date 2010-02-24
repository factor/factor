USING: destructors io io.encodings.binary io.files io.directories
io.files.temp io.ports kernel sequences math
specialized-arrays.instances.alien.c-types.int tools.test ;
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

[ ] [ "test.txt" temp-file delete-file ] unit-test
