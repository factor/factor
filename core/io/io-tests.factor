USING: arrays io io.files kernel math parser strings system
tools.test words namespaces io.encodings.8-bit
io.encodings.binary ;
IN: io.tests

[ f ] [
    "resource:core/io/test/no-trailing-eol.factor" run-file
    "foo" "io.tests" lookup
] unit-test

[
    "This is a line.\rThis is another line.\r"
] [
    "resource:core/io/test/mac-os-eol.txt" latin1 <file-reader>
    [ 500 read ] with-input-stream
] unit-test

[
    255
] [
    "resource:core/io/test/binary.txt" latin1 <file-reader>
    [ read1 ] with-input-stream >fixnum
] unit-test

! Make sure we use correct to_c_string form when writing
[ ] [ "\0" write ] unit-test

[
    {
        { "It seems " CHAR: J }
        { "obs has lost h" CHAR: i }
        { "s grasp on reality again.\n" f }
    }
] [
    [
        "resource:core/io/test/separator-test.txt"
        latin1 <file-reader> [
            "J" read-until 2array ,
            "i" read-until 2array ,
            "X" read-until 2array ,
        ] with-input-stream
    ] { } make
] unit-test

[ ] [
    image binary [
        10 [ 65536 read drop ] times
    ] with-file-reader
] unit-test
