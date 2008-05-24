USING: html.templates html.templates.chloe
tools.test io.streams.string kernel sequences ascii boxes
namespaces xml html.components
splitting ;
IN: html.templates.chloe.tests

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
    "resource:extra/html/templates/chloe/test/"
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

[ ] [ blank-values ] unit-test

[ ] [ "A label" "label" set-value ] unit-test

SINGLETON: link-test

M: link-test link-title drop "<Link Title>" ;

M: link-test link-href drop "http://www.apple.com/foo&bar" ;

[ ] [ link-test "link" set-value ] unit-test

[ ] [ "int x = 5;" "code" set-value ] unit-test

[ ] [ "c" "mode" set-value ] unit-test

[ ] [ { 1 2 3 } "inspector" set-value ] unit-test

[ ] [ "<p>a paragraph</p>" "html" set-value ] unit-test

[ ] [ "sheeple" "field" set-value ] unit-test

[ ] [ "a password" "password" set-value ] unit-test

[ ] [ "a\nb\nc" "textarea" set-value ] unit-test

[ ] [ "new york" "choice" set-value ] unit-test

[ ] [ { "new york" "detroit" "minneapolis" } "choices" set-value ] unit-test
    
[ ] [
    [
        "test8" test-template call-template
    ] run-template drop
] unit-test
