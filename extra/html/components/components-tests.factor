IN: html.components.tests
USING: html.components tools.test kernel io.streams.string
io.streams.null accessors ;

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
        "green" <textarea> 25 >>rows 30 >>columns render
    ] with-null-writer
] unit-test

[ ] [ blank-values ] unit-test

[ ] [ "new york" "city1" set-value ] unit-test

[ ] [
    [
        "city1"
        <choice>
            { "new york" "los angeles" "chicago" } >>choices
        render
    ] with-null-writer
] unit-test

[ ] [ { "los angeles" "new york" } "city2" set-value ] unit-test

[ ] [
    [
        "city2"
        <choice>
            { "new york" "los angeles" "chicago" } >>choices
            t >>multiple
        render
    ] with-null-writer
] unit-test

[ ] [
    [
        "city2"
        <choice>
            { "new york" "los angeles" "chicago" } >>choices
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
