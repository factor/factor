! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays html5 io.encodings.utf8 io.files kernel multiline
sequences strings tools.test ;
IN: html5.tests

: child-tags ( tag -- tags ) children>> [ tag? ] filter >array ;
: html-root ( string -- tag ) parse-html5 tree>> [ tag? ] find nip ;
: body-root ( string -- tag ) html-root child-tags last ;

DEFER: node-text
: node-text ( obj -- string )
    dup tag? [ children>> [ node-text ] map concat ] [
        dup comment? [ drop "" ] when
    ] if ;

{ "The content" } [
    [[ <!DOCTYPE html><html><head></head><body>The content</body></html>]]
    body-root node-text
] unit-test

! Implicit document elements, void elements, and unclosed tags at EOF.
{ { "head" "body" } } [
    "<p>Hello<br>world<img src=x>" html-root child-tags [ name>> ] map
] unit-test

{ "Helloworld" } [
    "<p>Hello<br>world<img src=x>" body-root node-text
] unit-test

{ { "br" "img" } } [
    "<p>Hello<br>world<img src=x>" body-root child-tags first
    child-tags [ name>> ] map
] unit-test

! Title uses RCDATA; script/style preserve markup and ampersands literally.
{ { "title" "script" "style" } } [
    [[ <!doctype html><title>Nansen &amp; Norway</title><script>if (a < b) x="&amp;";</script><style>a>b{content:"&amp;"}</style><body>Done]]
    html-root child-tags first child-tags [ name>> ] map
] unit-test

{ { "Nansen & Norway" "if (a < b) x=\"&amp;\";" "a>b{content:\"&amp;\"}" } } [
    [[ <!doctype html><title>Nansen &amp; Norway</title><script>if (a < b) x="&amp;";</script><style>a>b{content:"&amp;"}</style><body>Done]]
    html-root child-tags first child-tags [ node-text ] map
] unit-test

{ "x</not-title>y" } [
    "<title>x</not-title>y</title>" html-root child-tags first
    child-tags first node-text
] unit-test

! Named references use the longest match; numeric references are decoded.
{ "& © ¬it; &unknown; & € A A" } [
    "<p>&amp; &copy &notit; &unknown; &#38; &#x80; &#65 &#x41;</p>"
    body-root node-text
] unit-test

{ { { "href" "?a=1&lang=en&notit;&x=2" } { "title" "a & b" } { "hidden" "" } } } [
    [[ <a href="?a=1&lang=en&notit;&x=2" title = "a &amp; b" hidden>link</a>]]
    body-root child-tags first attributes>> >array
] unit-test

{ "&" } [ "<p>&" body-root node-text ] unit-test

{ { "head" "body" } } [
    "" html-root child-tags [ name>> ] map
] unit-test

{ { "head" "body" } } [
    "<title>Nansen</title>" html-root child-tags [ name>> ] map
] unit-test

{ "html" } [
    "<!DOCTYPE html><p>Nansen</p>" parse-html5 tree-doctype>> name>>
] unit-test
