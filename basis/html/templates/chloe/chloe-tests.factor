USING: html.templates html.templates.chloe
tools.test io.streams.string kernel sequences ascii boxes
namespaces xml html.components html.forms
splitting furnace accessors
html.templates.chloe.compiler ;
IN: html.templates.chloe.tests

! So that changes to code are reflected
{ } [ reset-cache ] unit-test

: run-template ( quot -- string )
    with-string-writer [ "\r\n\t" member? ] reject
    [ CHAR: \s = ] trim ; inline

: test-template ( name -- template )
    "vocab:html/templates/chloe/test/"
    prepend <chloe> ;

{ "Hello world" } [
    [
        "test1" test-template call-template
    ] run-template
] unit-test

{ "Blah blah" "Hello world" } [
    [
        <box> title set
        [
            "test2" test-template call-template
        ] run-template
        title get box>
    ] with-scope
] unit-test

{ "<!DOCTYPE html><html><head><title>Hello world</title></head><body>Blah blah</body></html>" } [
    [
        [
            "test2" test-template call-template
        ] "test3" test-template with-boilerplate
    ] run-template
] unit-test

: test4-aux? ( -- ? ) t ;

{ "True" } [
    [
        "test4" test-template call-template
    ] run-template
] unit-test

: test5-aux? ( -- ? ) f ;

{ "" } [
    [
        "test5" test-template call-template
    ] run-template
] unit-test

{ } [ begin-form ] unit-test

{ } [ "A label" "label" set-value ] unit-test

SINGLETON: link-test

M: link-test link-title drop "<Link Title>" ;

M: link-test link-href drop "http://www.apple.com/foo&bar" ;

{ } [ link-test "link" set-value ] unit-test

{ } [ "int x = 5;" "code" set-value ] unit-test

{ } [ "c" "mode" set-value ] unit-test

{ } [ { 1 2 3 } "inspector" set-value ] unit-test

{ } [ "<p>a paragraph</p>" "html" set-value ] unit-test

{ } [ "sheeple" "field" set-value ] unit-test

{ } [ "a password" "password" set-value ] unit-test

{ } [ "a\nb\nc" "textarea" set-value ] unit-test

{ } [ "new york" "choice" set-value ] unit-test

{ } [ { "new york" "detroit" "minneapolis" } "choices" set-value ] unit-test

{ } [
    [
        "test8" test-template call-template
    ] run-template drop
] unit-test

{ } [ { 1 2 3 } "numbers" set-value ] unit-test

{ "<ul><li>1</li><li>2</li><li>3</li></ul>" } [
    [
        "test7" test-template call-template
    ] run-template [ ascii:blank? ] reject
] unit-test

TUPLE: person first-name last-name ;

{ } [
    {
        T{ person f "RBaxter" "Unknown" }
        T{ person f "Doug" "Coleman" }
    } "people" set-value
] unit-test

{ "<table><tr><td>RBaxter</td><td>Unknown</td></tr><tr><td>Doug</td><td>Coleman</td></tr></table>" } [
    [
        "test8" test-template call-template
    ] run-template [ ascii:blank? ] reject
] unit-test

{ } [
    {
        H{ { "first-name" "RBaxter" } { "last-name" "Unknown" } }
        H{ { "first-name" "Doug"    } { "last-name" "Coleman" } }
    } "people" set-value
] unit-test

{ "<table><tr><td>RBaxter</td><td>Unknown</td></tr><tr><td>Doug</td><td>Coleman</td></tr></table>" } [
    [
        "test8" test-template call-template
    ] run-template [ ascii:blank? ] reject
] unit-test

{ } [ 1 "id" set-value ] unit-test

{ "<a name=\"1\">Hello</a>" } [
    [
        "test9" test-template call-template
    ] run-template
] unit-test

{ } [ H{ { "a" H{ { "b" "c" } } } } values set ] unit-test

{ "<form method=\"post\" action=\"foo\"><div style=\"display: none;\"><input type=\"hidden\" value=\"a\" name=\"__n\"/></div></form>" } [
    [
        "test10" test-template call-template
    ] run-template
] unit-test

{ } [ begin-form ] unit-test

{ } [
    <form> H{ { "first-name" "RBaxter" } { "last-name" "Unknown" } } >>values "person" set-value
] unit-test

{ "<table><tr><td>RBaxter</td><td>Unknown</td></tr></table>" } [
    [
        "test11" test-template call-template
    ] run-template [ ascii:blank? ] reject
] unit-test

{ } [
    begin-form
    { "a" "b" } "choices" set-value
    "true" "b" set-value
] unit-test

{ "<input type=\"checkbox\" name=\"a\">a</input><input type=\"checkbox\" checked=\"true\" name=\"b\">b</input>" } [
    [
        "test12" test-template call-template
    ] run-template
] unit-test

[
    [
        "test13" test-template call-template
    ] run-template
] [ error>> T{ unknown-chloe-tag f "this-tag-does-not-exist" } = ] must-fail-with

{ "Hello &lt;world&gt; &amp;escaping test;" "Hello <world> &escaping test;" } [
    [
        <box> title set
        [
            begin-form
            "&escaping test;" "a-value" set-value
            "test14" test-template call-template
        ] run-template
        title get box>
    ] with-scope
] unit-test

[
    [
        <box> title set
        [
            "test15" test-template call-template
        ] run-template
    ] with-scope
] [ error>> tag-not-allowed-here? ] must-fail-with

{ "This is     <style type=\"text/css\"> * { font-family: monospace; } </style>" } [
    V{ } clone style [
        [ "test16" test-template call-template ] run-template
    ] with-variable
] unit-test

{ "<script type=\"text/javascript\">/* <![CDATA[*/function testAlerts() {    window.alert(\"Hello, world!\");}/*]]> */</script>" } [
    V{ } clone script [
        [ "test17" test-template call-template ] run-template
    ] with-variable
] unit-test

{ "<meta name=\"author\" content=\"John Doe\"/><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"/>" } [
    V{ } clone meta [
        [ "test18" test-template call-template ] run-template
    ] with-variable
] unit-test


{ "<style>&<>></style><script>&<>></script>" } [
    [ "test19" test-template call-template ] run-template
] unit-test
