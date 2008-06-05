IN: furnace.tests
USING: http.server.dispatchers http.server.responses
http.server furnace tools.test kernel namespaces accessors
io.streams.string ;
TUPLE: funny-dispatcher < dispatcher ;

: <funny-dispatcher> funny-dispatcher new-dispatcher ;

TUPLE: base-path-check-responder ;

C: <base-path-check-responder> base-path-check-responder

M: base-path-check-responder call-responder*
    2drop
    "$funny-dispatcher" resolve-base-path
    "text/plain" <content> ;

[ ] [
    <dispatcher>
        <dispatcher>
            <funny-dispatcher>
                <base-path-check-responder> "c" add-responder
            "b" add-responder
        "a" add-responder
    main-responder set
] unit-test

[ "/a/b/" ] [
    V{ } responder-nesting set
    "a/b/c" split-path main-responder get call-responder body>>
] unit-test

[ "<input type='hidden' name='foo' value='&amp;&amp;&amp;'/>" ]
[ [ "&&&" "foo" hidden-form-field ] with-string-writer ]
unit-test
