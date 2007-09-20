USING: io.streams.duplex io kernel continuations tools.test ;
IN: temporary

! Test duplex stream close behavior
TUPLE: closing-stream closed? ;

: <closing-stream> closing-stream construct-empty ;

M: closing-stream stream-close
    dup closing-stream-closed? [
        "Closing twice!" throw
    ] [
        t swap set-closing-stream-closed?
    ] if ;

TUPLE: unclosable-stream ;

: <unclosable-stream> unclosable-stream construct-empty ;

M: unclosable-stream stream-close
    "Can't close me!" throw ;

[ ] [
    <closing-stream> <closing-stream> <duplex-stream>
    dup stream-close stream-close
] unit-test

[ t ] [
    <unclosable-stream> <closing-stream> [
        <duplex-stream>
        [ dup stream-close ] catch 2drop
    ] keep closing-stream-closed?
] unit-test

[ t ] [
    <closing-stream> [ <unclosable-stream>
        <duplex-stream>
        [ dup stream-close ] catch 2drop
    ] keep closing-stream-closed?
] unit-test
