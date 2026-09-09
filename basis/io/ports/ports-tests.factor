USING: accessors alien.c-types alien.data destructors io
io.encodings.ascii io.encodings.binary io.encodings.string
io.encodings.utf8 io.files io.pipes io.ports io.sockets kernel libc
locals math namespaces sequences tools.test ;

! Make sure that writing malloced storage to a file works, and
! also make sure that writes larger than the buffer size work

[| path |

    { } [
        path binary [
            [
                100,000 <iota>
                0
                100,000 int malloc-array &free [ copy ] keep write
            ] with-destructors
        ] with-file-writer
    ] unit-test

    { t } [
        path binary [
            100,000 4 * read int cast-array 100,000 <iota> sequence=
        ] with-file-reader
    ] unit-test

] with-test-file

! Delimiters at a buffer boundary and after multiple refills must
! consume exactly one byte. An unterminated tail differs from EOF.
[| path |
    B{ 97 98 99 100 10 10 101 102 103 104 105 106 10 107 108 }
    path binary set-file-contents
    { B{ 97 98 99 100 } 10 B{ } 10 B{ 101 102 103 104 105 106 } 10
      B{ 107 108 } f f f } [
        4 default-buffer-size [
            path binary [
                "\n" read-until
                "\n" read-until
                "\n" read-until
                "\n" read-until
                "\n" read-until
            ] with-file-reader
        ] with-variable
    ] unit-test
] with-test-file

[| path |
    B{ 97 98 99 100 101 102 103 104 } path binary set-file-contents
    { B{ 97 98 99 100 101 102 103 104 } f f f } [
        4 default-buffer-size [
            path binary [ "\n" read-until "\n" read-until ] with-file-reader
        ] with-variable
    ] unit-test
] with-test-file

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
