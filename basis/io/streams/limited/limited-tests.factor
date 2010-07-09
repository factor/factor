USING: accessors continuations destructors io io.encodings
io.encodings.ascii io.encodings.binary
io.encodings.string io.encodings.utf8 io.files io.pipes
io.streams.byte-array io.streams.limited io.streams.string
kernel namespaces strings tools.test system
io.encodings.8-bit.latin1 ;
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

[ "are you " ] [ "decoded" get stream-readln ] unit-test

[ f ] [ "decoded" get stream-readln ] unit-test


[ ] [
    "abc\ndef\nghi"
    ascii encode binary <byte-reader> "data" set
] unit-test

[ ] [ "data" get 4 <limited-stream> "limited" set ] unit-test

[ "abc" CHAR: \n ]
[ "\n" "limited" get stream-read-until [ >string ] dip ] unit-test

[ "" f ] [ "\n" "limited" get stream-read-until [ >string ] dip ] unit-test


[ CHAR: a ]
[ "a" <string-reader> 1 <limited-stream> stream-read1 ] unit-test

[ "abc" ]
[
    "abc" <string-reader> 3 <limited-stream>
    4 swap stream-read
] unit-test

[ f ]
[
    "abc" <string-reader> 3 <limited-stream>
    4 over stream-read drop 10 swap stream-read
] unit-test

[ t ]
[
    "abc" <string-reader> 3 limit-stream unlimit-stream
    "abc" <string-reader> =
] unit-test

[ t ]
[
    "abc" <string-reader> 3 limit-stream unlimit-stream
    "abc" <string-reader> =
] unit-test

[ t ]
[
    [
        "resource:license.txt" utf8 <file-reader> &dispose
        3 limit-stream unlimit-stream
        "resource:license.txt" utf8 <file-reader> &dispose
        [ decoder? ] both?
    ] with-destructors
] unit-test


[ "asdf" ] [
    "asdf" <string-reader> 2 <limited-stream> [
        unlimited-input contents
    ] with-input-stream
] unit-test

! pipes are duplex and not seekable
[ "as" ] [
    latin1 <pipe> [ 2 <limited-stream> ] change-in
    "asdf" over stream-write dup stream-flush
    2 swap stream-read
] unit-test

[ "as" ] [
    latin1 <pipe> [ 2 <limited-stream> ] change-in
    "asdf" over stream-write dup stream-flush
    3 swap stream-read
] unit-test

! test seeking on limited unseekable streams
[ "as" ] [
    latin1 <pipe> [ 2 <limited-stream> ] change-in
    "asdf" over stream-write dup stream-flush
    2 swap stream-read
] unit-test

[ "as" ] [
    latin1 <pipe> [ 2 <limited-stream> ] change-in
    "asdf" over stream-write dup stream-flush
    3 swap stream-read
] unit-test
