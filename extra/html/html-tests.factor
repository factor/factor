USING: html http io io.streams.string io.styles kernel
namespaces tools.test xml.writer sbufs sequences html.private ;
IN: temporary

: make-html-string
    [ with-html-stream ] string-out ;

[ ] [
    512 <sbuf> <html-stream> drop
] unit-test

[ "" ] [
    [ "" write ] make-html-string
] unit-test

[ "a" ] [
    [ CHAR: a write1 ] make-html-string
] unit-test

[ "&lt;" ] [
    [ "<" write ] make-html-string
] unit-test

[ "<" ] [
    [ "<" H{ } stdio get format-html-span ] make-html-string
] unit-test

TUPLE: funky town ;

M: funky browser-link-href
    "http://www.funky-town.com/" swap funky-town append ;

[ "<a href='http://www.funky-town.com/austin'>&lt;</a>" ] [
    [
        "<" "austin" funky construct-boa write-object
    ] make-html-string
] unit-test

[ "<span style='font-family: monospace; '>car</span>" ]
[
    [
        "car"
        H{ { font "monospace" } }
        format
    ] make-html-string
] unit-test

[ "<span style='color: #ff00ff; '>car</span>" ]
[
    [
        "car"
        H{ { foreground { 1 0 1 1 } } }
        format
    ] make-html-string
] unit-test

[ "<div style='background-color: #ff00ff; '>cdr</div>" ]
[
    [
        H{ { page-color { 1 0 1 1 } } }
        [ "cdr" write ] with-nesting
    ] make-html-string
] unit-test
