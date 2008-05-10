USING: io.streams.duplex io io.streams.string
kernel continuations tools.test ;
IN: io.streams.duplex.tests

! Test duplex stream close behavior
TUPLE: closing-stream closed? ;

: <closing-stream> closing-stream new ;

M: closing-stream dispose
    dup closing-stream-closed? [
        "Closing twice!" throw
    ] [
        t swap set-closing-stream-closed?
    ] if ;

TUPLE: unclosable-stream ;

: <unclosable-stream> unclosable-stream new ;

M: unclosable-stream dispose
    "Can't close me!" throw ;

[ ] [
    <closing-stream> <closing-stream> <duplex-stream>
    dup dispose dispose
] unit-test

[ t ] [
    <unclosable-stream> <closing-stream> [
        <duplex-stream>
        [ dup dispose ] [ 2drop ] recover
    ] keep closing-stream-closed?
] unit-test

[ t ] [
    <closing-stream> [ <unclosable-stream>
        <duplex-stream>
        [ dup dispose ] [ 2drop ] recover
    ] keep closing-stream-closed?
] unit-test

[ "Hey" ] [
    "Hey\nThere" <string-reader> <string-writer> <duplex-stream>
    stream-readln
] unit-test
