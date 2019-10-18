USING: io io.pipes io.streams.string io.encodings.utf8
io.encodings.binary io.streams.duplex io.encodings io.timeouts
namespaces continuations tools.test kernel calendar destructors
accessors debugger math sequences ;
IN: io.pipes.tests

[ "Hello" ] [
    utf8 <pipe> [
        "Hello" print flush
        readln
    ] with-stream
] unit-test

[ { } ] [ { } run-pipeline ] unit-test
[ { f } ] [ { [ f ] } run-pipeline ] unit-test
[ { "Hello" } ] [
    "Hello" [
        { [ input-stream [ utf8 <decoder> ] change readln ] } run-pipeline
    ] with-string-reader
] unit-test

[ { f "Hello" } ] [
    {
        [ output-stream [ utf8 <encoder> ] change "Hello" print flush f ]
        [ input-stream [ utf8 <decoder> ] change readln ]
    } run-pipeline
] unit-test

[
    utf8 <pipe> [
        1 seconds over set-timeout
        stream-readln
    ] with-disposal
] must-fail

[ ] [
    1000 [
        utf8 <pipe> [
            [ in>> dispose ]
            [ out>> "hi" over stream-write dispose ]
            bi
        ] curry ignore-errors
    ] times
] unit-test

! 0 read should not block
[ f ] [
    [
        binary <pipe> &dispose
        in>>
        [ 0 read ] with-input-stream
    ] with-destructors
] unit-test
