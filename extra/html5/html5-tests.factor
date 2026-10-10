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

! Template contents are a separate fragment, including nested templates.
: head-root ( string -- tag ) html-root child-tags first ;
: template-content-tags ( tag -- tags ) template-contents>> [ tag? ] filter >array ;

{ t } [
    "<body><template><p>x</template>" body-root child-tags first children>> empty?
] unit-test
{ "x" } [
    "<template><p>x</template>" head-root child-tags first template-content-tags first node-text
] unit-test
{ { "head" "body" } } [
    "<template><div>" html-root child-tags [ name>> ] map
] unit-test
{ "x" } [
    "<template><template><span>x" head-root child-tags first
    template-content-tags first template-content-tags first node-text
] unit-test
{ { "template" "p" } } [
    "<body><template><div></template><p>x" body-root child-tags [ name>> ] map
] unit-test
{ { "tr" } } [
    "<template><tr><td>x" head-root child-tags first template-content-tags [ name>> ] map
] unit-test
{ { "td" "td" } } [
    "<template><td>x</td><tbody><td>y" head-root child-tags first
    template-content-tags [ name>> ] map
] unit-test
{ { "col" } } [
    "<template><col><div>x" head-root child-tags first template-content-tags [ name>> ] map
] unit-test
{ 1 } [
    "<template><col>x" head-root child-tags first template-contents>> length
] unit-test
{ { "tr" "div" } } [
    "<table><template><tr><div>x" body-root child-tags first child-tags first
    template-content-tags [ name>> ] map
] unit-test
{ { "table" "p" } } [
    "<table><template><tr></template></table><p>x" body-root child-tags [ name>> ] map
] unit-test
{ "x" } [
    "<div><template></div>x" body-root child-tags first child-tags first
    template-contents>> concat
] unit-test
{ t } [
    "<head></head><template>x</template>" head-root child-tags first template-contents>> empty? not
] unit-test
{ { "script" "td" } } [
    "<template><script>x</script><td>y" head-root child-tags first
    template-content-tags [ name>> ] map
] unit-test
{ t } [
    "<template><svg><template/>" head-root child-tags first template-content-tags first
    child-tags first template-contents>> f =
] unit-test
{ t } [
    "<template><div>" parse-html5 template-insertion-modes>> empty?
] unit-test
{ t } [
    "<template><div>" parse-html5 parse-errors>> "eof-in-template" swap member?
] unit-test

! Small HTML recovery rules and obsolete aliases.
{ { { "a" "first" } { "b" "new" } } } [
    "<html a=first><body><html a=second b=new>" html-root attributes>> >array
] unit-test
{ { { "a" "first" } { "b" "new" } } } [
    "<body a=first><p>x<body a=second b=new>" body-root attributes>> >array
] unit-test
{ { { "a" "first" } } } [
    "<html a=first><template><html b=new>" html-root attributes>> >array
] unit-test
{ { { "a" "first" } } } [
    "<body a=first><template><body b=new>" body-root attributes>> >array
] unit-test
{ { "p" } } [
    "<body><head><p>x" body-root child-tags [ name>> ] map
] unit-test
{ { "img" "p" } } [
    "<image src=x><p>y" body-root child-tags [ name>> ] map
] unit-test
{ "image" t } [
    "<svg><image/>" body-root child-tags first child-tags first
    [ name>> ] [ namespace>> svg-namespace = ] bi
] unit-test
{ { "h3" "p" } } [
    "<h3>x</h2><p>y" body-root child-tags [ name>> ] map
] unit-test
{ "y" } [
    "<h1><div><h3><span></h1>y" body-root child-tags first child-tags first children>> last
] unit-test
{ { "button" "button" } } [
    "<button><p>x<button>y" body-root child-tags [ name>> ] map
] unit-test
{ { "basefont" "bgsound" "meta" } } [
    "<head><basefont><bgsound><meta>" head-root child-tags [ name>> ] map
] unit-test
{ t } [
    "<head><noscript><basefont><!--x--></noscript>" head-root child-tags first
    children>> last comment?
] unit-test

! Frameset modes and eligibility to replace an implicit body.
{ { "head" "frameset" } } [
    "<frameset><frame>" html-root child-tags [ name>> ] map
] unit-test
{ { "frame" "frame" } } [
    "<frameset><frame/><frame>" html-root child-tags last child-tags [ name>> ] map
] unit-test
{ { "frameset" "frame" } } [
    "<frameset><frameset><frame></frameset><frame>" html-root child-tags last
    child-tags [ name>> ] map
] unit-test
{ "frameset" } [
    "<div><p> <frameset><frame>" html-root child-tags last name>>
] unit-test
{ { "body" "body" "body" } } [
    { "<body><frameset>" "x<frameset>" "<div><body><frameset>" }
    [ html-root child-tags last name>> ] map
] unit-test
{ { "frameset" "body" } } [
    { "<input type=HIDDEN><frameset>" "<input><frameset>" }
    [ html-root child-tags last name>> ] map
] unit-test
{ { "body" "body" "body" "body" "body" "body" "body" } } [
    { "<button><frameset>" "<pre><frameset>" "<li><frameset>"
      "<table><frameset>" "<img><frameset>" "<textarea></textarea><frameset>"
      "<select></select><frameset>" }
    [ html-root child-tags last name>> ] map
] unit-test
{ { "frameset" "frameset" "frameset" } } [
    { "<param><frameset>" "<source><frameset>" "<track><frameset>" }
    [ html-root child-tags last name>> ] map
] unit-test
{ "frameset" } [
    "<svg>\0 </svg><frameset>" html-root child-tags last name>>
] unit-test
{ "body" } [
    "<svg>&#0;</svg><frameset>" html-root child-tags last name>>
] unit-test
{ "frameset" } [
    "<svg><![CDATA[\0]]></svg><frameset>" html-root child-tags last name>>
] unit-test
{ "frameset" } [
    "<template>x</template><p><frameset>" html-root child-tags last name>>
] unit-test
{ "   " } [
    "<frameset> a b <div>x</div>" html-root child-tags last node-text
] unit-test
{ "<p>fallback</p>" } [
    "<frameset><noframes><p>fallback</p></noframes><frame>" html-root child-tags last
    child-tags first node-text
] unit-test
{ { "frameset" "noframes" } } [
    "<frameset></frameset><noframes>x</noframes><div>" html-root child-tags [ name>> ] map rest
] unit-test
{ t } [
    "<frameset></frameset></html><!--end-->" parse-html5 tree>> last comment?
] unit-test
{ "frameset" } [
    "<p><noscript>text</noscript><frameset>" t parse-html5-with-scripting tree>> first
    child-tags last name>>
] unit-test

! Formatting reconstruction and adoption agency recovery.
DEFER: tag-shape
: tag-shape ( tag -- shape )
    [ name>> ] [ child-tags [ tag-shape ] map ] bi 2array ;
: body-shapes ( string -- shapes ) body-root child-tags [ tag-shape ] map ;

{ { { "b" { { "i" { } } } } { "i" { } } } } [
    "<b><i>one</b>two</i>three" body-shapes
] unit-test
{ { "one" "two" } } [
    "<b><i>one</b>two</i>three" body-root child-tags [ node-text ] map
] unit-test
{ { { "b" { } } { "p" { { "b" { } } } } } } [
    "<b><p>one</b>two" body-shapes
] unit-test
{ "onetwo" } [
    "<b><p>one</b>two" body-root child-tags last node-text
] unit-test
{ { { "p" { { "b" { } } } } { "p" { { "b" { } } } } } } [
    "<p><b>one<p>two" body-shapes
] unit-test
{ { { "a" { } } { "a" { } } } } [
    "<a href=one>one<a href=two>two" body-shapes
] unit-test
{ { "one" "two" } } [
    "<a href=one>one<a href=two>two" body-root child-tags [ attributes>> first second ] map
] unit-test
{ { { "nobr" { } } { "nobr" { } } } } [
    "<nobr>one<nobr>two" body-shapes
] unit-test
{ { { "b" { { "b" { { "b" {  } } } } } } } } [
    "<p><b><b><b><b>one<p>two" body-root child-tags last child-tags [ tag-shape ] map
] unit-test
{ { { "b" { { "table" { { "tbody" { { "tr" { { "td" {  } } { "td" {  } } } } } } } } } } } } [
    "<b><table><td>one<td>two" body-shapes
] unit-test
{ { "a" "a" "table" } } [
    "<table><a>one<td>two</td>three</table>" body-root child-tags [ name>> ] map
] unit-test
{ { { "object" { { "b" { } } } } { "p" { } } } } [
    "<object><b>one</object><p>two" body-shapes
] unit-test
{ { { "template" { } } { "p" { } } } } [
    "<body><template><b>one</template><p>two" body-shapes
] unit-test
{ { "a" "table" } } [
    "<template><a><table><a>" head-root child-tags first template-content-tags first
    child-tags [ name>> ] map
] unit-test
{ { "p" "i" } } [
    "<svg><foreignObject><p><i>one</p>two" body-root child-tags first child-tags first
    child-tags [ name>> ] map
] unit-test
{ { "p" "i" } } [
    "<math><mtext><p><i>one</p>two" body-root child-tags first child-tags first
    child-tags [ name>> ] map
] unit-test
{ { { "font" { { "select" { { "option" {  } } } } } } } } [
    "<font><select><option>one</option></font></select>" body-shapes
] unit-test
{ t } [
    "<b><p>one</b>two" body-root child-tags last dup child-tags first parent>> eq?
] unit-test
{ t } [
    "<template><a><table><a>" head-root child-tags first template-content-tags first
    dup child-tags last parent>> eq?
] unit-test

! Form pointers, scope, and table insertion.
{ { { "form" {  } } } } [
    "<form><form>" body-shapes
] unit-test
{ { { "form" { { "div" { { "div" {  } } } } } } } } [
    "<!doctype html><form><div></form><div>" body-shapes
] unit-test
{ { { "p" {  } } { "form" {  } } } } [
    "<p>one<form>two" body-shapes
] unit-test
{ { { "form" { { "p" {  } } } } { "div" {  } } } } [
    "<form><p>one</form><div>two" body-shapes
] unit-test
{ { { "form" { { "table" {  } } { "form" {  } } } } } } [
    "<form><table></form></table><form>" body-shapes
] unit-test
{ { { "table" { { "form" {  } } } } } } [
    "<table><form><form>" body-shapes
] unit-test
{ { { "table" { { "form" {  } } } } } } [
    "<table><form></table><form>" body-shapes
] unit-test
{ { { "table" { { "form" {  } } } } { "form" {  } } } } [
    "<table><form></form></table><form>" body-shapes
] unit-test
{ { { "input" {  } } { "div" {  } } { "table" { { "form" {  } } { "input" {  } } } } } } [
    "<table><form><input type=hidden><input></form><div></div></table>" body-shapes
] unit-test
{ { { "table" { { "input" {  } } } } } } [
    "<table><input type=hidDEN></table>" body-shapes
] unit-test
{ f } [
    "<form><table></form>" parse-html5 form-element-pointer>>
] unit-test
{ { "form" "form" } } [
    "<form><template><form></form></template></form><form>" body-root child-tags [ name>> ] map
] unit-test
{ "form" } [
    "<form><template><form></template>" body-root child-tags first child-tags first
    template-content-tags first name>>
] unit-test
{ f } [
    "<template><form></template>" parse-html5 form-element-pointer>>
] unit-test
{ { "form" "div" } } [
    "<template><form><div></form><div>" head-root child-tags first template-content-tags
    [ name>> ] map
] unit-test
{ { "form" "input" } } [
    "<template><table><form><input type=hidden>" head-root child-tags first
    template-content-tags first child-tags [ name>> ] map
] unit-test
