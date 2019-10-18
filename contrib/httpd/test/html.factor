IN: temporary
USING: html io kernel namespaces styles test ;

[
    "&lt;html&gt;&amp;&apos;sgml&apos;"
] [ "<html>&'sgml'" chars>entities ] unit-test

[ "/foo/bar" ]
[
    [
        "/home/slava/doc/" "doc-root" set
        "/home/slava/doc/foo/bar" file-link-href
    ] with-scope
] unit-test

[ "" ]
[
    [
        [ ] [ drop ] span-tag
    ] string-out
] unit-test

[ "<span style='color: #ff00ff; font-family: Monospaced; '>car</span>" ]
[
    [
        [ [ foreground 1 0 1 ] [[ font "Monospaced" ]] ]
        [ drop "car" write ]
        span-tag
    ] string-out
] unit-test

: html-format ( string style -- string )
    [ format ] with-html-stream ;

[ "hello world" ]
[
    [ "hello world" [ ] html-format ] string-out
] unit-test

[ "<span style='color: #ff00ff; font-family: Monospaced; '>car</span>" ]
[
    [
        "car"
        [ [ foreground 1 0 1 ] [[ font "Monospaced" ]] ]
        html-format
    ] string-out
] unit-test

[
    "<html><head><title>Foo</title></head><body><h1>Foo</h1></body></html>"
] [
    [
        "Foo" [ ] html-document
    ] string-out
] unit-test

[
    "<html><head><title>Foo</title></head><body><h1>Foo</h1><pre>Hi</pre></body></html>"
] [
    [
        "Foo" [ "Hi" write ] simple-html-document
    ] string-out
] unit-test
