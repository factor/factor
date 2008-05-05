USING: io io.pipes io.streams.string io.encodings.utf8
io.streams.duplex io.encodings namespaces continuations
tools.test kernel ;
IN: io.pipes.tests

[ "Hello" ] [
    utf8 <pipe> [
        "Hello" print flush
        readln
    ] with-stream
] unit-test

[ { } ] [ { } with-pipeline ] unit-test
[ { f } ] [ { [ f ] } with-pipeline ] unit-test
[ { "Hello" } ] [
    "Hello" [
        { [ input-stream [ utf8 <decoder> ] change readln ] } with-pipeline
    ] with-string-reader
] unit-test

[ { f "Hello" } ] [
    {
        [ output-stream [ utf8 <encoder> ] change "Hello" print flush f ]
        [ input-stream [ utf8 <decoder> ] change readln ]
    } with-pipeline
] unit-test
