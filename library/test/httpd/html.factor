IN: scratchpad
USE: html
USE: namespaces
USE: stdio
USE: streams
USE: strings
USE: test
USE: stack

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

[ "<img src='/responder/resource/library/icons/File.png'>" ]
[
    [
        ""
        [ [ "icon" | "library/icons/File.png" ] ]
        [ drop ] icon-tag
    ] with-string
] unit-test

[ "" ]
[
    [
        [ ] [ drop ] span-tag
    ] with-string
] unit-test

[ "<span style='color: #ff00ff; font-family: Monospaced; '>car</span>" ]
[
    [
        [ [ "fg" 255 0 255 ] [ "font" | "Monospaced" ] ]
        [ drop "car" write ]
        span-tag
    ] with-string
] unit-test

: html-write-attr ( string style -- string )
    [ write-attr ] with-html-stream ;

[ "hello world" ]
[
    [ "hello world" [ ] html-write-attr ] with-string
] unit-test

[ "<span style='color: #ff00ff; font-family: Monospaced; '>car</span>" ]
[
    [
        "car"
        [ [ "fg" 255 0 255 ] [ "font" | "Monospaced" ] ]
        html-write-attr
    ] with-string
] unit-test

[
    "<html><head><title>Foo</title></head><body><h1>Foo</h1></body></html>"
] [
    [
        "Foo" [ ] html-document
    ] with-string
] unit-test

[
    "<html><head><title>Foo</title></head><body><h1>Foo</h1><pre>Hi</pre></body></html>"
] [
    [
        "Foo" [ "Hi" write ] simple-html-document
    ] with-string
] unit-test
