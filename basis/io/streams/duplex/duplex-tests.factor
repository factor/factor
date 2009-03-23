USING: io.streams.duplex io io.streams.string
kernel continuations tools.test destructors accessors ;
IN: io.streams.duplex.tests

! Test duplex stream close behavior
TUPLE: closing-stream < disposable ;

: <closing-stream> ( -- stream ) closing-stream new ;

M: closing-stream dispose* drop ;

TUPLE: unclosable-stream ;

: <unclosable-stream> ( -- stream ) unclosable-stream new ;

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
    ] keep disposed>>
] unit-test

[ t ] [
    <closing-stream> [ <unclosable-stream>
        <duplex-stream>
        [ dup dispose ] [ 2drop ] recover
    ] keep disposed>>
] unit-test

[ "Hey" ] [
    "Hey\nThere" <string-reader> <string-writer> <duplex-stream>
    stream-readln
] unit-test
