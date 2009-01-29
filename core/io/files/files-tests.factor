USING: tools.test io.files io.files.private io.files.temp
io.directories io.encodings.8-bit arrays make system
io.encodings.binary io threads kernel continuations
io.encodings.ascii sequences strings accessors
io.encodings.utf8 math destructors namespaces ;
IN: io.files.tests

\ exists? must-infer
\ (exists?) must-infer

[ ] [ "append-test" temp-file dup exists? [ delete-file ] [ drop ] if ] unit-test

[ ] [ "append-test" temp-file ascii <file-appender> dispose ] unit-test

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
