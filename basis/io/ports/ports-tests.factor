USING: accessors alien.c-types alien.data destructors io
io.directories io.encodings.ascii io.encodings.binary
io.encodings.string io.encodings.utf8 io.files io.files.temp
io.pipes io.sockets kernel libc math namespaces sequences
tools.test ;
IN: io.ports.tests

! Make sure that writing malloced storage to a file works, and
! also make sure that writes larger than the buffer size work

{ } [
    "test.txt" temp-file binary [
        [
            100,000 iota
            0
            100,000 int malloc-array &free [ copy ] keep write
        ] with-destructors
    ] with-file-writer
] unit-test

{ t } [
    "test.txt" temp-file binary [
        100,000 4 * read int cast-array 100,000 iota sequence=
    ] with-file-reader
] unit-test

{ } [ "test.txt" temp-file delete-file ] unit-test

! Getting the stream-element-type of an output-port was broken
{ +byte+ } [ binary <pipe> [ stream-element-type ] with-disposal ] unit-test
{ +byte+ } [ binary <pipe> [ out>> stream-element-type ] with-disposal ] unit-test
{ +character+ } [ ascii <pipe> [ stream-element-type ] with-disposal ] unit-test
{ +character+ } [ ascii <pipe> [ out>> stream-element-type ] with-disposal ] unit-test

! Issue #1256 regression test
! Port length would be zero before data is received
{ f } [
    "google.com" 80 <inet> binary [
        "GET /\n" utf8 encode write flush
        input-stream get stream-contents
    ] with-client empty?
] unit-test
