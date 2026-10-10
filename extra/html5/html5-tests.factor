! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators html5 kernel multiline
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

! Tokenizer parse errors recover and remain available on the document.
{ "FOOBAZ" } [ "FOO<!-- BAR --!>BAZ" body-root node-text ] unit-test
{ " BAR --! >BAZ" } [
    "FOO<!-- BAR --! >BAZ" body-root children>> [ comment? ] find nip payload>>
] unit-test
{ "" } [ "<!" parse-html5 tree>> first payload>> ] unit-test
{ "foo" } [ "<!foo>" parse-html5 tree>> first payload>> ] unit-test
{ "<1</" } [ "<1</" body-root node-text ] unit-test
{ "x" } [ "x<a href='unfinished" body-root node-text ] unit-test
{ { "eof-in-tag" } } [
    "x<a href='unfinished" parse-html5 parse-errors>> >array
] unit-test
{ { "duplicate-attribute" } } [
    "<a href=x HREF=y>" parse-html5 parse-errors>> >array
] unit-test
{ { { "href" "x" } } } [
    "<a href=x HREF=y>" body-root child-tags first attributes>> >array
] unit-test
{ "� � � \u10fffe" } [
    "&#xD800; &#x110000; &#0; &#x10FFFE;" body-root node-text
] unit-test
{ "a\nb\nc" } [ "a\r\nb\rc" body-root node-text ] unit-test
{ "A" } [ "<pre>\nA</pre>" body-root child-tags first node-text ] unit-test
{ "\nA" } [ "<textarea>\n\nA</textarea>" body-root child-tags first node-text ] unit-test
{ { "potato" "pub" "sys" } } [
    [[ <!DOCTYPE potato PUBLIC"pub" 'sys'>Hello]] parse-html5 tree-doctype>>
    [ name>> ] [ public-identifier>> >string ] [ system-identifier>> >string ] tri 3array
] unit-test
{ "Hello" } [ "<!DOCTYPE potato sYstEM>Hello" body-root node-text ] unit-test
{ { "One" "Two" } } [
    "<p>One<p>Two" body-root child-tags [ node-text ] map
] unit-test
{ { "a" "b" } } [
    "<ul><li>a<li>b</ul>" body-root child-tags first child-tags [ node-text ] map
] unit-test
{ { "a" "b" } } [
    "<dl><dt>a<dd>b</dl>" body-root child-tags first child-tags [ node-text ] map
] unit-test
{ { "h1" "h2" } } [
    "<h1>a<h2>b" body-root child-tags [ name>> ] map
] unit-test
{ { "p" "div" } } [
    "<p>a<div>b</div>" body-root child-tags [ name>> ] map
] unit-test
{ "</scriptx>BAR" } [
    "<script></scriptx>BAR" html-root child-tags first child-tags first node-text
] unit-test
{ "<!-- <sCrIpt> --!</script>BAR" } [
    "<script><!-- <sCrIpt> --!</script>BAR" html-root child-tags first child-tags first node-text
] unit-test

{ { "hello" "there?again" } } [
    "<?hello   there?again?>" parse-html5 tree>> first
    [ target>> ] [ data>> ] bi 2array
] unit-test
{ "?xml version='1.0'?" } [
    "<?xml version='1.0'?>" parse-html5 tree>> first payload>>
] unit-test
{ "?bad$" } [ "<?bad$>" parse-html5 tree>> first payload>> ] unit-test
{ { "eof-in-processing-instruction" } } [
    "<?hello" parse-html5 parse-errors>> >array
] unit-test
{ t } [
    "<body></body><?hello>" parse-html5 tree>> first children>> last processing-instruction?
] unit-test
{ t } [
    "<body></body></html><?hello>" parse-html5 tree>> last processing-instruction?
] unit-test
{ "<p>hidden</p>" } [
    "<noscript><p>hidden</p></noscript>" t parse-html5-with-scripting
    tree>> [ tag? ] find nip child-tags first child-tags first node-text
] unit-test

{ "tbody" } [
    "<table><td>x" body-root child-tags first child-tags first name>>
] unit-test
{ "tr" } [
    "<table><td>x" body-root child-tags first child-tags first child-tags first name>>
] unit-test
{ { "a" "b" } } [
    "<table><tr><td>a<td>b" body-root child-tags first child-tags first
    child-tags first child-tags [ node-text ] map
] unit-test
{ { "tr" "tr" } } [
    "<table><td><tr>" body-root child-tags first child-tags first
    child-tags [ name>> ] map
] unit-test
{ { "table" } } [
    "<table> x<tr><td>y</table>" body-root child-tags [ name>> ] map
] unit-test
{ " xy" } [
    "<table> x<tr><td>y</table>" body-root node-text
] unit-test
{ { "p" "table" } } [
    "<table><p>x</p><tr><td>y</table>" body-root child-tags [ name>> ] map
] unit-test
{ "colgroup" } [
    "<table><col>" body-root child-tags first child-tags first name>>
] unit-test

! Foreign content preserves namespaces, case, and self-closing elements.
{ t } [ "<svg/>" body-root child-tags first namespace>> svg-namespace = ] unit-test
{ t } [ "<math/>" body-root child-tags first namespace>> mathml-namespace = ] unit-test
{ { "svg" "p" } } [
    "<svg/><p>x" body-root child-tags [ name>> ] map
] unit-test
{ { "path" "g" } } [
    "<svg><path/><g/>" body-root child-tags first child-tags [ name>> ] map
] unit-test
{ "linearGradient" } [
    "<svg><lineargradient/>" body-root child-tags first child-tags first name>>
] unit-test
{ { { "viewBox" "0 0 10 10" } { "filterres" "2" } } } [
    "<svg viewbox='0 0 10 10' filterRes='2' />" body-root child-tags first attributes>> >array
] unit-test
{ { { "definitionURL" "x" } } } [
    "<math definitionurl=x>" body-root child-tags first attributes>> >array
] unit-test
{ "xlink" "href" t "x" } [
    "<svg xlink:href=x>" body-root child-tags first attributes>> first first2
    [ [ prefix>> ] [ name>> ] [ namespace>> xlink-namespace = ] tri ] dip
] unit-test
{ f "xmlns" t } [
    "<math xmlns=x>" body-root child-tags first attributes>> first first
    [ prefix>> ] [ name>> ] [ namespace>> xmlns-namespace = ] tri
] unit-test
{ t } [
    "<svg xml:base=x>" body-root child-tags first attributes>> first first string?
] unit-test
{ t } [
    "<svg><foreignObject><div>x" body-root child-tags first child-tags first
    child-tags first namespace>> html-namespace =
] unit-test
{ t } [
    "<math><mtext><span>x" body-root child-tags first child-tags first
    child-tags first namespace>> html-namespace =
] unit-test
{ t } [
    "<math><mi><mglyph/>" body-root child-tags first child-tags first
    child-tags first namespace>> mathml-namespace =
] unit-test
{ t } [
    "<math><annotation-xml encoding='TEXT/HTML'><div>" body-root child-tags first
    child-tags first child-tags first namespace>> html-namespace =
] unit-test
{ t } [
    "<math><annotation-xml><svg/>" body-root child-tags first child-tags first
    child-tags first namespace>> svg-namespace =
] unit-test
{ { "svg" "p" } } [
    "<svg><g><p>x" body-root child-tags [ name>> ] map
] unit-test
{ { "svg" "br" "foo" } } [
    "<svg></br><foo>" body-root child-tags [ name>> ] map
] unit-test
{ "<b>�x" } [
    "<svg><![CDATA[<b>\0x]]>" body-root node-text
] unit-test
{ "x" } [
    "<svg><title><b>x</b></title></svg>" body-root node-text
] unit-test
{ "a" } [
    "<p><svg><foreignObject><p>a" body-root child-tags first child-tags first
    child-tags first child-tags first node-text
] unit-test
{ "a" } [
    "<div><svg><foreignObject><p></div>a" body-root child-tags first child-tags first
    child-tags first child-tags first node-text
] unit-test
