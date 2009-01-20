USING: io io.streams.limited io.encodings io.encodings.string
io.encodings.ascii io.encodings.binary io.streams.byte-array
namespaces tools.test strings kernel io.streams.string accessors ;
IN: io.streams.limited.tests

[ ] [
    "hello world\nhow are you today\nthis is a very long line indeed"
    ascii encode binary <byte-reader> "data" set
] unit-test

[ ] [ "data" get 24 <limited-stream> "limited" set ] unit-test

[ CHAR: h ] [ "limited" get stream-read1 ] unit-test

[ ] [ "limited" get ascii <decoder> "decoded" set ] unit-test

[ "ello world" ] [ "decoded" get stream-readln ] unit-test

[ "how " ] [ 4 "decoded" get stream-read ] unit-test

[ "decoded" get stream-readln ] [ limit-exceeded? ] must-fail-with

[ ] [
    "abc\ndef\nghi"
    ascii encode binary <byte-reader> "data" set
] unit-test

[ ] [ "data" get 7 <limited-stream> "limited" set ] unit-test

[ "abc" CHAR: \n ] [ "\n" "limited" get stream-read-until [ >string ] dip ] unit-test

[ "\n" "limited" get stream-read-until ] [ limit-exceeded? ] must-fail-with

[ "he" CHAR: l ] [
    B{ CHAR: h CHAR: e CHAR: l CHAR: l CHAR: o }
    ascii <byte-reader> [
        5 limit-input
        "l" read-until
    ] with-input-stream
] unit-test

[ CHAR: a ]
[ "a" <string-reader> 1 <limited-stream> stream-read1 ] unit-test

[ "abc" ]
[
    "abc" <string-reader> 3 <limited-stream> stream-eofs >>mode
    4 swap stream-read
] unit-test

[ f ]
[
    "abc" <string-reader> 3 <limited-stream> stream-eofs >>mode
    4 over stream-read drop 10 swap stream-read
] unit-test
