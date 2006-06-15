IN: temporary
USING: html http io kernel namespaces styles test xml ;

[
    "/responder/foo?z=%20"
] [
    "/responder/foo" H{ { "z" " " } } build-url
] unit-test

[
    "&lt;html&gt;&amp;&apos;sgml&apos;"
] [ "<html>&'sgml'" chars>entities ] unit-test

[ "/foo/bar" ]
[
    [
        "/home/slava/doc/" "doc-root" set
        "/home/slava/doc/foo/bar" <pathname> browser-link-href
    ] with-scope
] unit-test

[ "" ]
[
    [
        H{ } [ drop ] span-tag
    ] string-out
] unit-test

: html-format ( string style -- string )
    [ format ] with-html-stream ;

[ "hello world" ]
[
    [ "hello world" H{ } html-format ] string-out
] unit-test

[ "<span style='font-family: monospace; '>car</span>" ]
[
    [
        "car"
        H{ { font "monospace" } }
        html-format
    ] string-out
] unit-test

[ "<span style='color: #ff00ff; '>car</span>" ]
[
    [
        "car"
        H{ { foreground { 1 0 1 1 } } }
        html-format
    ] string-out
] unit-test
