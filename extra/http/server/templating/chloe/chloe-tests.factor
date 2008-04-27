USING: http.server.templating http.server.templating.chloe
http.server.components http.server.boilerplate tools.test
io.streams.string kernel sequences ascii boxes namespaces xml
splitting ;
IN: http.server.templating.chloe.tests

[ "foo" ]
[ "<a href=\"foo\">blah</a>" string>xml "href" required-attr ]
unit-test

[ "<a name=\"foo\">blah</a>" string>xml "href" required-attr ]
[ "href attribute is required" = ]
must-fail-with

[ f ] [ f parse-query-attr ] unit-test

[ f ] [ "" parse-query-attr ] unit-test

[ H{ { "a" "b" } } ] [
    blank-values
    "b" "a" set-value
    "a" parse-query-attr
] unit-test

[ H{ { "a" "b" } { "c" "d" } } ] [
    blank-values
    "b" "a" set-value
    "d" "c" set-value
    "a,c" parse-query-attr
] unit-test

: run-template
    with-string-writer [ "\r\n\t" member? not ] filter
    "?>" split1 nip ; inline

: test-template ( name -- template )
    "resource:extra/http/server/templating/chloe/test/"
    swap
    ".xml" 3append <chloe> ;

[ "Hello world" ] [
    [
        "test1" test-template call-template
    ] run-template
] unit-test

[ "Blah blah" "Hello world" ] [
    [
        <box> title set
        [
            "test2" test-template call-template
        ] run-template
        title get box>
    ] with-scope
] unit-test

[ "<html><head><title>Hello world</title></head><body>Blah blah</body></html>" ] [
    [
        [
            "test2" test-template call-template
        ] "test3" test-template with-boilerplate
    ] run-template
] unit-test

: test4-aux? t ;

[ "True" ] [
    [
        "test4" test-template call-template
    ] run-template
] unit-test

: test5-aux? f ;

[ "" ] [
    [
        "test5" test-template call-template
    ] run-template
] unit-test

SYMBOL: test6-aux?

[ "True" ] [
    [
        test6-aux? on
        "test6" test-template call-template
    ] run-template
] unit-test

SYMBOL: test7-aux?

[ "" ] [
    [
        test7-aux? off
        "test7" test-template call-template
    ] run-template
] unit-test
