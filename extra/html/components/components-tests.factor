IN: html.components.tests
USING: tools.test kernel io.streams.string
io.streams.null accessors inspector html.streams
html.components ;

[ ] [ blank-values ] unit-test

[ ] [ 3 "hi" set-value ] unit-test

[ 3 ] [ "hi" value ] unit-test

TUPLE: color red green blue ;

[ ] [ 1 2 3 color boa from-tuple ] unit-test

[ 1 ] [ "red" value ] unit-test

[ ] [ "jimmy" "red" set-value ] unit-test

[ "123.5" ] [ 123.5 object>string ] unit-test

[ "jimmy" ] [
    [
        "red" label render
    ] with-string-writer
] unit-test

[ ] [ "<jimmy>" "red" set-value ] unit-test

[ "&lt;jimmy&gt;" ] [
    [
        "red" label render
    ] with-string-writer
] unit-test

[ "<input type='hidden' name='red' value='<jimmy>'/>" ] [
    [
        "red" hidden render
    ] with-string-writer
] unit-test

[ ] [ "'jimmy'" "red" set-value ] unit-test

[ "<input type='text' size='5' name='red' value='&apos;jimmy&apos;'/>" ] [
    [
        "red" <field> 5 >>size render
    ] with-string-writer
] unit-test

[ "<input type='password' size='5' name='red' value=''/>" ] [
    [
        "red" <password> 5 >>size render
    ] with-string-writer
] unit-test

[ ] [
    [
        "green" <textarea> render
    ] with-null-writer
] unit-test

[ ] [
    [
        "green" <textarea> 25 >>rows 30 >>cols render
    ] with-null-writer
] unit-test

[ ] [ blank-values ] unit-test

[ ] [ "new york" "city1" set-value ] unit-test

[ ] [ { "new york" "los angeles" "chicago" } "cities" set-value ] unit-test

[ ] [
    [
        "city1"
        <choice>
            "cities" >>choices
        render
    ] with-null-writer
] unit-test

[ ] [ { "los angeles" "new york" } "city2" set-value ] unit-test

[ ] [
    [
        "city2"
        <choice>
            "cities" >>choices
            t >>multiple
        render
    ] with-null-writer
] unit-test

[ ] [
    [
        "city2"
        <choice>
            "cities" >>choices
            t >>multiple
            5 >>size
        render
    ] with-null-writer
] unit-test

[ ] [ blank-values ] unit-test

[ ] [ t "delivery" set-value ] unit-test

[ "<input type='checkbox' name='delivery' selected='true'>Delivery</input>" ] [
    [
        "delivery"
        <checkbox>
            "Delivery" >>label
        render
    ] with-string-writer
] unit-test

[ ] [ f "delivery" set-value ] unit-test

[ "<input type='checkbox' name='delivery'>Delivery</input>" ] [
    [
        "delivery"
        <checkbox>
            "Delivery" >>label
        render
    ] with-string-writer
] unit-test

SINGLETON: link-test

M: link-test link-title drop "<Link Title>" ;

M: link-test link-href drop "http://www.apple.com/foo&bar" ;

[ ] [ link-test "link" set-value ] unit-test

[ "<a href='http://www.apple.com/foo&amp;bar'>&lt;Link Title&gt;</a>" ] [
    [ "link" link render ] with-string-writer
] unit-test

[ ] [
    "<html>arbitrary <b>markup</b> for the win!</html>" "html" set-value
] unit-test

[ "<html>arbitrary <b>markup</b> for the win!</html>" ] [
    [ "html" html render ] with-string-writer
] unit-test

[ ] [ "int x = 4;" "code" set-value ] unit-test

[ ] [ "java" "mode" set-value ] unit-test

[ "<span class='KEYWORD3'>int</span> x <span class='OPERATOR'>=</span> <span class='DIGIT'>4</span>;\n" ] [
    [ "code" <code> "mode" >>mode render ] with-string-writer
] unit-test

[ ] [ "-foo\n-bar" "farkup" set-value ] unit-test

[ "<ul><li>foo</li><li>bar</li></ul>" ] [
    [ "farkup" farkup render ] with-string-writer
] unit-test

[ ] [ { 1 2 3 } "object" set-value ] unit-test

[ t ] [
    [ "object" inspector render ] with-string-writer
    [ "object" value [ describe ] with-html-stream ] with-string-writer
    =
] unit-test

[ ] [ blank-values ] unit-test

[ ] [
    "factor" [
        "concatenative" "model" set-value
    ] nest-values
] unit-test

[ H{ { "factor" H{ { "model" "concatenative" } } } } ] [ values get ] unit-test
