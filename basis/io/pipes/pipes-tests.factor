USING: accessors calendar concurrency.count-downs continuations
destructors fry io io.encodings io.encodings.binary
io.encodings.utf8 io.pipes io.streams.duplex io.streams.string
io.timeouts kernel math namespaces threads tools.test ;

{ "Hello" } [
    utf8 <pipe> [
        "Hello" print flush
        readln
    ] with-stream
] unit-test

! Test run-pipeline
{ { } } [ { } run-pipeline ] unit-test
{ { f } } [ { [ f ] } run-pipeline ] unit-test
{ { "Hello" } } [
    "Hello" [
        { [ input-stream [ utf8 <decoder> ] change readln ] } run-pipeline
    ] with-string-reader
] unit-test

{ { f "Hello" } } [
    {
        [ output-stream [ utf8 <encoder> ] change "Hello" print flush f ]
        [ input-stream [ utf8 <decoder> ] change readln ]
    } run-pipeline
] unit-test

! Test timeout
[
    utf8 <pipe> [
        1 seconds over set-timeout
        stream-readln
    ] with-disposal
] must-fail

! Test writing to a half-open pipe
{ } [
    1000 [
        utf8 <pipe> [
            [ in>> dispose ]
            [ out>> "hi" over stream-write dispose ]
            bi
        ] curry ignore-errors
    ] times
] unit-test

! Test non-blocking operation
{ } [
    [
        2 <count-down> "count-down" set

        utf8 <pipe> &dispose
        utf8 <pipe> &dispose
        [
            [
                '[
                    _ stream-read1 drop
                    "count-down" get count-down
                ] in-thread
            ] bi@

            ! Give the threads enough time to start blocking on
            ! read
            1 seconds sleep
        ]
        ! At this point, two threads are blocking on read
        [ [ "Hi" over stream-write stream-flush ] bi@ ]
        ! At this point, both threads should wake up
        2bi

        "count-down" get await
    ] with-destructors
] unit-test

! 0 read should not block
{ f } [
    [
        binary <pipe> &dispose
        in>>
        [ 0 read ] with-input-stream
    ] with-destructors
] unit-test

{ "bar" "foo" } [
    [
        [let
            utf8 <connected-pair> &dispose :> ( x y )
            "foo\n" x stream-write x stream-flush
            "bar\n" y stream-write y stream-flush
            x y [ stream-readln ] bi@
        ]
    ] with-destructors
] unit-test
