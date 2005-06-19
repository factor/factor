IN: temporary
USE: html
USE: namespaces
USE: io
USE: strings
USE: test
USE: kernel

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
        [ [[ "icon" "library/icons/File.png" ]] ]
        [ drop ] icon-tag
    ] string-out
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
        [ [ "fg" 255 0 255 ] [[ "font" "Monospaced" ]] ]
        [ drop "car" write ]
        span-tag
    ] string-out
] unit-test

: html-write-attr ( string style -- string )
    [ write-attr ] with-html-stream ;

[ "hello world" ]
[
    [ "hello world" [ ] html-write-attr ] string-out
] unit-test

[ "<span style='color: #ff00ff; font-family: Monospaced; '>car</span>" ]
[
    [
        "car"
        [ [ "fg" 255 0 255 ] [[ "font" "Monospaced" ]] ]
        html-write-attr
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
