USING: destructors io io.encodings io.encodings.latin1
io.encodings.ascii io.encodings.binary io.encodings.string
io.encodings.utf8 io.files io.pipes io.streams.byte-array
io.streams.duplex io.streams.limited io.streams.string kernel
namespaces strings tools.test ;

{ } [
    "hello world\nhow are you today\nthis is a very long line indeed"
    ascii encode binary <byte-reader> "data" set
] unit-test

{ } [ "data" get 24 <limited-stream> "limited" set ] unit-test

{ CHAR: h } [ "limited" get stream-read1 ] unit-test

{ } [ "limited" get ascii <decoder> "decoded" set ] unit-test

{ "ello world" } [ "decoded" get stream-readln ] unit-test

{ "how " } [ 4 "decoded" get stream-read ] unit-test

{ "are you " } [ "decoded" get stream-readln ] unit-test

{ f } [ "decoded" get stream-readln ] unit-test

{ } [
    "abc\ndef\nghi"
    ascii encode binary <byte-reader> "data" set
] unit-test

{ } [ "data" get 4 <limited-stream> "limited" set ] unit-test

{ "abc" CHAR: \n }
[ "\n" "limited" get stream-read-until [ >string ] dip ] unit-test

{ "" f } [ "\n" "limited" get stream-read-until [ >string ] dip ] unit-test

{ CHAR: a }
[ "a" <string-reader> 1 <limited-stream> stream-read1 ] unit-test

{ "abc" }
[
    "abc" <string-reader> 3 <limited-stream>
    4 swap stream-read
] unit-test

{ f }
[
    "abc" <string-reader> 3 <limited-stream>
    4 over stream-read drop 10 swap stream-read
] unit-test

! pipes are duplex and not seekable
{ "as" } [
    latin1 <pipe> [
        input-stream [ 2 <limited-stream> ] change
        "asdf" write flush 2 read
    ] with-stream
] unit-test

{ "as" } [
    latin1 <pipe> [
        input-stream [ 2 <limited-stream> ] change
        "asdf" write flush 3 read
    ] with-stream
] unit-test

! test seeking on limited unseekable streams
{ "as" } [
    latin1 <pipe> [
        input-stream [ 2 <limited-stream> ] change
        "asdf" write flush 2 read
    ] with-stream
] unit-test

{ "as" } [
    latin1 <pipe> [
        input-stream [ 2 <limited-stream> ] change
        "asdf" write flush 3 read
    ] with-stream
] unit-test

{ t }
[
    "abc" <string-reader> 3 limit-stream unlimit-stream
    "abc" <string-reader> =
] unit-test

{ t }
[
    "abc" <string-reader> 3 limit-stream unlimit-stream
    "abc" <string-reader> =
] unit-test

{ t }
[
    [
        "resource:LICENSE.txt" utf8 <file-reader> &dispose
        3 limit-stream unlimit-stream
        "resource:LICENSE.txt" utf8 <file-reader> &dispose
        [ decoder? ] both?
    ] with-destructors
] unit-test

{ "asdf" } [
    "asdf" <string-reader> 2 <limited-stream> [
        unlimited-input read-contents
    ] with-input-stream
] unit-test

{ "asdf" } [
    "asdf" <string-reader> 2 <limited-stream> [
        [ read-contents ] with-unlimited-input
    ] with-input-stream
] unit-test

{ "gh" } [
    "asdfgh" <string-reader> 4 <limited-stream> [
        2 [
            [ read-contents drop ] with-unlimited-input
        ] with-limited-input
        [ read-contents ] with-unlimited-input
    ] with-input-stream
] unit-test

{ 4 } [ B{ 0 1 2 3 4 5 } binary <byte-reader> 4 <limited-stream> stream-length ] unit-test
{ 6 } [ B{ 0 1 2 3 4 5 } binary <byte-reader> 8 <limited-stream> stream-length ] unit-test
