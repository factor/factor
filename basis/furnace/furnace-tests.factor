IN: furnace.tests
USING: http http.server.dispatchers http.server.responses
http.server furnace furnace.utilities tools.test kernel
namespaces accessors io.streams.string urls xml.writer ;
TUPLE: funny-dispatcher < dispatcher ;

: <funny-dispatcher> ( -- dispatcher ) funny-dispatcher new-dispatcher ;

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

[ "<input type=\"hidden\" value=\"&amp;&amp;&amp;\" name=\"foo\"/>" ]
[ "&&&" "foo" hidden-form-field xml>string ]
unit-test

[ f ] [ <request> request [ referrer ] with-variable ] unit-test

[ t ] [ URL" http://foo" dup url [ same-host? ] with-variable ] unit-test

[ f ] [ f URL" http://foo" url [ same-host? ] with-variable ] unit-test
