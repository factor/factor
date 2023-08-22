! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays destructors io io.encodings.ascii
io.encodings.binary io.files io.streams.byte-array
io.streams.memory io.streams.peek io.streams.string kernel make
namespaces sequences strings tools.test ;

{ CHAR: a }
[ "abc" <string-reader> <peek-stream> stream-read1 ] unit-test

{ CHAR: a }
[ "abc" <string-reader> <peek-stream> stream-peek1 ] unit-test

{ f }
[ "" <string-reader> <peek-stream> stream-peek1 ] unit-test

{ CHAR: a }
[ "abc" <string-reader> <peek-stream> stream-peek1 ] unit-test

{ "ab" 99 }
[ "abc" <string-reader> <peek-stream> "c" swap stream-read-until ] unit-test

{ "ab" f }
[ "ab" <string-reader> <peek-stream> "c" swap stream-read-until ] unit-test

{ CHAR: a }
[
    "abc" <string-reader> <peek-stream>
    [ stream-peek1 drop ]
    [ stream-peek1 ] bi
] unit-test

{ "ab" }
[
    "abc" <string-reader> <peek-stream>
    2 swap stream-peek
] unit-test

{ "ab" }
[
    "abc" <string-reader> <peek-stream>
    2 over stream-peek drop
    2 swap stream-peek
] unit-test

{
    {
        B{ 97 98 99 100 }
        B{ 97 98 99 100 101 102 }
        B{ 97 98 }
        B{ 99 100 }
        B{ 101 102 }
        B{ 103 104 }
        B{ 105 106 107 108 }
        B{ 105 106 107 108 109 110 111 112 }
        B{ 105 106 107 108 109 110 111 112 113 114 }
    }
} [
    [
        "abcdefghijklmnopqrstuvwxyz" >byte-array binary <byte-reader> <peek-stream>
        4 over stream-peek ,
        6 over stream-peek ,
        2 over stream-read ,
        2 over stream-read ,
        2 over stream-read ,
        2 over stream-read ,
        4 over stream-peek ,
        8 over stream-peek ,
        10 swap stream-read ,
    ] { } make
] unit-test

{
    {
        "abcd"
        "abcdef"
        "ab"
        "cd"
        "ef"
        "gh"
        "ijkl"
        "ijklmnop"
        "ijklmnopqr"
    }
}
[
    [
        "abcdefghijklmnopqrstuvwxyz" >byte-array ascii <byte-reader> <peek-stream>
        4 over stream-peek ,
        6 over stream-peek ,
        2 over stream-read ,
        2 over stream-read ,
        2 over stream-read ,
        2 over stream-read ,
        4 over stream-peek ,
        8 over stream-peek ,
        10 swap stream-read ,
    ] { } make
] unit-test

{
    {
        B{ 0 1 2 3 }
        B{ 0 1 2 3 4 5 }
        B{ 0 1 }
        B{ 2 3 }
        B{ 4 5 }
        B{ 6 7 }
        B{ 8 9 10 11 }
        B{ 8 9 10 11 12 13 14 15 }
        B{ 8 9 10 11 12 13 14 15 16 17 }
    }
}
[
    [
        [
            26 <iota> >byte-array <memory-stream> <peek-stream>
            4 over stream-peek ,
            6 over stream-peek ,
            2 over stream-read ,
            2 over stream-read ,
            2 over stream-read ,
            2 over stream-read ,
            4 over stream-peek ,
            8 over stream-peek ,
            10 swap stream-read ,
        ] { } make
    ] with-destructors
] unit-test

! Issue #1317
{ "Cop" } [
    "resource:LICENSE.txt" binary [
        input-stream [ <peek-stream> ] change
        peek1 drop
        3 read >string
    ] with-file-reader
] unit-test

{ "yri" } [
    "resource:LICENSE.txt" binary [
        input-stream [ <peek-stream> ] change
        peek1 drop
        3 read drop
        2 peek drop
        3 read >string
    ] with-file-reader
] unit-test
