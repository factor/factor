USING: accessors assocs concurrency.mailboxes destructors
io.encodings.binary io.pipes io.streams.duplex io.streams.null
io.streams.string kernel linked-assocs msgpack msgpack.rpc
msgpack.rpc.private sequences strings tools.test ;

IN: msgpack.rpc.tests

{
    T{ notification { method "foo" } { params { } } }
} [
    [let
        f :> result!
        <session> [ result! ] >>notification-callback
        "foo" { } <notification>
        feed-packet
        result
    ]
] unit-test

{ { 1 } } [
    <session>
    [ 1 "test-method" { } <request> feed-packet ] keep
    incoming-requests>> keys
] unit-test

[
    1 { } <response-ok>
    <session>
    swap
    feed-packet
] [ unknown-response? ] must-fail-with

{
    T{ request { msgid 20 } { method "testing" } { params { } } }
} [
    { 0 20 "testing" { } } parse-packet
] unit-test

{ "\x02¤test\x01\x02\x03" } [
    [ "test" { 1 2 3 } <notification> write-msgpack ]
    with-string-writer
] unit-test

: roundtrip-test ( packet -- )
    dup
    [ write-msgpack ] with-string-writer
    [ ?read-packet ] with-string-reader
    assert= ;

{ } [
    { [ "test" { 1 2 3 } <notification> ]
      [ 123 LH{ { 1 2 } } <response-ok> ]
      [ 2 LH{ { 1 2 } } <response-error> ]
      [ 1 "foobar" "baz" <request> ]
    }
    [ call roundtrip-test ] each
] unit-test

{
    T{ response
       { msgid 1 }
       { error +msgpack-nil+ }
       { result "result" } }
} [
    [let
        f :> result!
        <session>
        dup 1 "m" { } <request> [ result! ] feed-request
        1 "result" <response-ok>
        feed-packet
        result
    ]
] unit-test

{ } [
    null-reader null-writer <duplex-stream>
    <connection> [ start ] [ stop ] bi
] unit-test

{ T{ notification f "meth" { 1 } } } [
    [let
        <mailbox> :> finish
        [ "meth" { 1 } <notification> write-msgpack ] with-string-writer
        <string-reader> null-writer <duplex-stream> <connection> :> session
        [ session stop finish mailbox-put ]
        session session>> notification-callback<<
        session start
        finish mailbox-get
    ]
] unit-test

{ T{ response f 10 +msgpack-nil+ "done" } } [
    [let
        <mailbox> :> finish
        <string-writer> :> output
        [ 10 "meth" { 1 } <request> write-msgpack ] with-string-writer
        <string-reader> output <duplex-stream> <connection> :> session
        [ msgid>> "done" <response-ok> session send-response
          session stop t finish mailbox-put ]
        session session>> request-callback<<
        session start
        finish mailbox-get drop
        output >string [ ?read-packet ] with-string-reader
    ]
] unit-test

{ "result" } [
    [
        [let
            binary <connected-pair> [ &dispose ] bi@ :> ( x y )
            x <connection> :> sx
            y <connection> :> sy
            [ [ msgid>> ] [ params>> ] bi <response-ok> sx send-response ]
            sx session>> request-callback<<
            sx sy [ start ] bi@
            1 "test" "result" <request> sy send-request-await
            result>>
            sx sy [ stop ] bi@
        ]
    ] with-destructors
] unit-test
