USING: html.templates html.templates.chloe
tools.test io.streams.string kernel sequences ascii boxes
namespaces xml html.components html.forms
splitting furnace accessors
html.templates.chloe.compiler ;
IN: html.templates.chloe.tests

: run-template ( quot -- string )
    with-string-writer [ "\r\n\t" member? not ] filter
    "?>" split1 nip ; inline

: test-template ( name -- template )
    "vocab:html/templates/chloe/test/"
    prepend <chloe> ;

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

: test4-aux? ( -- ? ) t ;

[ "True" ] [
    [
        "test4" test-template call-template
    ] run-template
] unit-test

: test5-aux? ( -- ? ) f ;

[ "" ] [
    [
        "test5" test-template call-template
    ] run-template
] unit-test

[ ] [ begin-form ] unit-test

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

[ ] [ { 1 2 3 } "numbers" set-value ] unit-test

[ "<ul><li>1</li><li>2</li><li>3</li></ul>" ] [
    [
        "test7" test-template call-template
    ] run-template [ blank? not ] filter
] unit-test

TUPLE: person first-name last-name ;

[ ] [
    {
        T{ person f "RBaxter" "Unknown" }
        T{ person f "Doug" "Coleman" }
    } "people" set-value
] unit-test

[ "<table><tr><td>RBaxter</td><td>Unknown</td></tr><tr><td>Doug</td><td>Coleman</td></tr></table>" ] [
    [
        "test8" test-template call-template
    ] run-template [ blank? not ] filter
] unit-test

[ ] [
    {
        H{ { "first-name" "RBaxter" } { "last-name" "Unknown" } }
        H{ { "first-name" "Doug"    } { "last-name" "Coleman" } }
    } "people" set-value
] unit-test

[ "<table><tr><td>RBaxter</td><td>Unknown</td></tr><tr><td>Doug</td><td>Coleman</td></tr></table>" ] [
    [
        "test8" test-template call-template
    ] run-template [ blank? not ] filter
] unit-test

[ ] [ 1 "id" set-value ] unit-test

[ "<a name=\"1\">Hello</a>" ] [
    [
        "test9" test-template call-template
    ] run-template
] unit-test

[ ] [ H{ { "a" H{ { "b" "c" } } } } values set ] unit-test

[ "<form method=\"post\" action=\"foo\"><div style=\"display: none;\"><input type=\"hidden\" value=\"a\" name=\"__n\"/></div></form>" ] [
    [
        "test10" test-template call-template
    ] run-template
] unit-test

[ ] [ begin-form ] unit-test

[ ] [
    <form> H{ { "first-name" "RBaxter" } { "last-name" "Unknown" } } >>values "person" set-value
] unit-test

[ "<table><tr><td>RBaxter</td><td>Unknown</td></tr></table>" ] [
    [
        "test11" test-template call-template
    ] run-template [ blank? not ] filter
] unit-test

[ ] [
    begin-form
    { "a" "b" } "choices" set-value
    "true" "b" set-value
] unit-test

[ "<input type=\"checkbox\" name=\"a\">a</input><input type=\"checkbox\" checked=\"true\" name=\"b\">b</input>" ] [
    [
        "test12" test-template call-template
    ] run-template
] unit-test

[
    [
        "test13" test-template call-template
    ] run-template
] [ error>> T{ unknown-chloe-tag f "this-tag-does-not-exist" } = ] must-fail-with
