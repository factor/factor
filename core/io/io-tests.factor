USING: arrays io io.files kernel math parser strings system
tools.test words namespaces ;
IN: temporary

[ f ] [
    "resource:/core/io/test/no-trailing-eol.factor" run-file
    "foo" "temporary" lookup
] unit-test

: <resource-reader> ( resource -- stream )
    resource-path <file-reader> ;

[
    "This is a line.\rThis is another line.\r"
] [
    "/core/io/test/mac-os-eol.txt" <resource-reader>
    [ 500 read ] with-stream
] unit-test

[
    255
] [
    "/core/io/test/binary.txt" <resource-reader>
    [ read1 ] with-stream >fixnum
] unit-test

! Make sure we use correct to_c_string form when writing
[ ] [ "\0" write ] unit-test

[ "" ] [ 0 read ] unit-test

! [ ] [ "123" write 9000 CHAR: x <string> write flush ] unit-test

[ "" ] [
    "/core/io/test/binary.txt" <resource-reader>
    [ 0.2 read ] with-stream
] unit-test

[
    {
        { "It seems " CHAR: J }
        { "obs has lost h" CHAR: i }
        { "s grasp on reality again.\n" f }
    }
] [
    [
        "/core/io/test/separator-test.txt" <resource-reader> [
            "J" read-until 2array ,
            "i" read-until 2array ,
            "X" read-until 2array ,
        ] with-stream
    ] { } make
] unit-test

[ ] [
    image <file-reader> [
        10 [ 65536 read drop ] times
    ] with-stream
] unit-test
