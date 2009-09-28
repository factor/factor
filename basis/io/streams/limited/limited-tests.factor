USING: io io.streams.limited io.encodings io.encodings.string
io.encodings.ascii io.encodings.binary io.streams.byte-array
namespaces tools.test strings kernel io.streams.string accessors
io.encodings.utf8 io.files destructors ;
IN: io.streams.limited.tests

[ ] [
    "hello world\nhow are you today\nthis is a very long line indeed"
    ascii encode binary <byte-reader> "data" set
] unit-test

[ ] [ "data" get 24 stream-throws <limited-stream> "limited" set ] unit-test

[ CHAR: h ] [ "limited" get stream-read1 ] unit-test

[ ] [ "limited" get ascii <decoder> "decoded" set ] unit-test

[ "ello world" ] [ "decoded" get stream-readln ] unit-test

[ "how " ] [ 4 "decoded" get stream-read ] unit-test

[ "decoded" get stream-readln ] [ limit-exceeded? ] must-fail-with

[ ] [
    "abc\ndef\nghi"
    ascii encode binary <byte-reader> "data" set
] unit-test

[ ] [ "data" get 7 stream-throws <limited-stream> "limited" set ] unit-test

[ "abc" CHAR: \n ] [ "\n" "limited" get stream-read-until [ >string ] dip ] unit-test

[ "\n" "limited" get stream-read-until ] [ limit-exceeded? ] must-fail-with

[ "he" CHAR: l ] [
    B{ CHAR: h CHAR: e CHAR: l CHAR: l CHAR: o }
    ascii <byte-reader> [
        5 stream-throws limit-input
        "l" read-until
    ] with-input-stream
] unit-test

[ CHAR: a ]
[ "a" <string-reader> 1 stream-eofs <limited-stream> stream-read1 ] unit-test

[ "abc" ]
[
    "abc" <string-reader> 3 stream-eofs <limited-stream>
    4 swap stream-read
] unit-test

[ f ]
[
    "abc" <string-reader> 3 stream-eofs <limited-stream>
    4 over stream-read drop 10 swap stream-read
] unit-test

[ t ]
[
    "abc" <string-reader> 3 stream-eofs limit unlimited
    "abc" <string-reader> =
] unit-test

[ t ]
[
    "abc" <string-reader> 3 stream-eofs limit unlimited
    "abc" <string-reader> =
] unit-test

[ t ]
[
    [
        "resource:license.txt" utf8 <file-reader> &dispose
        3 stream-eofs limit unlimited
        "resource:license.txt" utf8 <file-reader> &dispose
        [ decoder? ] both?
    ] with-destructors
] unit-test

[ "HELL" ] [
    "HELLO"
    [ f stream-throws limit-input 4 read ]
    with-string-reader
] unit-test


[ "asdf" ] [
    "asdf" <string-reader> 2 stream-eofs <limited-stream> [
        unlimited-input contents
    ] with-input-stream
] unit-test
