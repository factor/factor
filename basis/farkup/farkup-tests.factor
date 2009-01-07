! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: farkup kernel peg peg.ebnf tools.test namespaces xml
urls.encoding assocs xml.utilities ;
IN: farkup.tests

relative-link-prefix off
disable-images? off
link-no-follow? off

[ "Baz" ] [ "Foo/Bar/Baz" simple-link-title ] unit-test
[ "Baz" ] [ "Baz" simple-link-title ] unit-test

[ ] [
    "abcd-*strong*\nasdifj\nweouh23ouh23" parse-farkup drop
] unit-test

[ ] [
    "abcd-*strong*\nasdifj\nweouh23ouh23\n" parse-farkup drop
] unit-test

[ "<p>a-b</p>" ] [ "a-b" convert-farkup ] unit-test
[ "<p>*foo\nbar\n</p>" ] [ "*foo\nbar\n" convert-farkup ] unit-test
[ "<p><strong>Wow!</strong></p>" ] [ "*Wow!*" convert-farkup ] unit-test
[ "<p><em>Wow.</em></p>" ] [ "_Wow._" convert-farkup ] unit-test

[ "<p>*</p>" ] [ "*" convert-farkup ] unit-test
[ "<p>*</p>" ] [ "\\*" convert-farkup ] unit-test
[ "<p>**</p>" ] [ "\\**" convert-farkup ] unit-test

[ "<ul><li>a-b</li></ul>" ] [ "-a-b" convert-farkup ] unit-test
[ "<ul><li>foo</li></ul>" ] [ "-foo" convert-farkup ] unit-test
[ "<ul><li>foo</li>\n</ul>" ] [ "-foo\n" convert-farkup ] unit-test
[ "<ul><li>foo</li>\n<li>bar</li></ul>" ] [ "-foo\n-bar" convert-farkup ] unit-test
[ "<ul><li>foo</li>\n<li>bar</li>\n</ul>" ] [ "-foo\n-bar\n" convert-farkup ] unit-test

[ "<ul><li>foo</li>\n</ul><p>bar\n</p>" ] [ "-foo\nbar\n" convert-farkup ] unit-test

[ "<ol><li>a-b</li></ol>" ] [ "#a-b" convert-farkup ] unit-test
[ "<ol><li>foo</li></ol>" ] [ "#foo" convert-farkup ] unit-test
[ "<ol><li>foo</li>\n</ol>" ] [ "#foo\n" convert-farkup ] unit-test
[ "<ol><li>foo</li>\n<li>bar</li></ol>" ] [ "#foo\n#bar" convert-farkup ] unit-test
[ "<ol><li>foo</li>\n<li>bar</li>\n</ol>" ] [ "#foo\n#bar\n" convert-farkup ] unit-test

[ "<ol><li>foo</li>\n</ol><p>bar\n</p>" ] [ "#foo\nbar\n" convert-farkup ] unit-test


[ "\n\n" ] [ "\n\n" convert-farkup ] unit-test
[ "\n\n" ] [ "\r\n\r\n" convert-farkup ] unit-test
[ "\n\n\n\n" ] [ "\r\r\r\r" convert-farkup ] unit-test
[ "\n\n\n" ] [ "\r\r\r" convert-farkup ] unit-test
[ "\n\n\n" ] [ "\n\n\n" convert-farkup ] unit-test
[ "<p>foo\n</p><p>bar</p>" ] [ "foo\n\nbar" convert-farkup ] unit-test
[ "<p>foo\n</p><p>bar</p>" ] [ "foo\r\n\r\nbar" convert-farkup ] unit-test
[ "<p>foo\n</p><p>bar</p>" ] [ "foo\r\rbar" convert-farkup ] unit-test
[ "<p>foo\n</p><p>bar</p>" ] [ "foo\r\r\nbar" convert-farkup ] unit-test

[ "\n<p>bar\n</p>" ] [ "\nbar\n" convert-farkup ] unit-test
[ "\n<p>bar\n</p>" ] [ "\rbar\r" convert-farkup ] unit-test
[ "\n<p>bar\n</p>" ] [ "\r\nbar\r\n" convert-farkup ] unit-test

[ "<p>foo\n</p><p>bar</p>" ] [ "foo\n\n\nbar" convert-farkup ] unit-test

[ "" ] [ "" convert-farkup ] unit-test

[ "<p>|a</p>" ]
[ "|a" convert-farkup ] unit-test

[ "<table><tr><td>a</td></tr></table>" ]
[ "|a|" convert-farkup ] unit-test

[ "<table><tr><td>a</td><td>b</td></tr></table>" ]
[ "|a|b|" convert-farkup ] unit-test

[ "<table><tr><td>a</td><td>b</td></tr><tr><td>c</td><td>d</td></tr></table>" ]
[ "|a|b|\n|c|d|" convert-farkup ] unit-test

[ "<table><tr><td>a</td><td>b</td></tr><tr><td>c</td><td>d</td></tr></table>" ]
[ "|a|b|\n|c|d|\n" convert-farkup ] unit-test

[ "<p><strong>foo</strong>\n</p><h1>aheading</h1>\n<p>adfasd</p>" ]
[ "*foo*\n=aheading=\nadfasd" convert-farkup ] unit-test

[ "<h1>foo</h1>\n" ] [ "=foo=\n" convert-farkup ] unit-test
[ "<p>lol</p><h1>foo</h1>\n" ] [ "lol=foo=\n" convert-farkup ] unit-test
[ "<p>=foo\n</p>" ] [ "=foo\n" convert-farkup ] unit-test
[ "<p>=foo</p>" ] [ "=foo" convert-farkup ] unit-test
[ "<p>==foo</p>" ] [ "==foo" convert-farkup ] unit-test
[ "<p>=</p><h1>foo</h1>" ] [ "==foo=" convert-farkup ] unit-test
[ "<h2>foo</h2>" ] [ "==foo==" convert-farkup ] unit-test
[ "<h2>foo</h2>" ] [ "==foo==" convert-farkup ] unit-test
[ "<p>=</p><h2>foo</h2>" ] [ "===foo==" convert-farkup ] unit-test
[ "<h1>foo</h1><p>=</p>" ] [ "=foo==" convert-farkup ] unit-test

[ "<pre><span class='KEYWORD3'>int</span> <span class='FUNCTION'>main</span><span class='OPERATOR'>(</span><span class='OPERATOR'>)</span>\n</pre>" ]
[ "[c{int main()}]" convert-farkup ] unit-test

[ "<p><img src='lol.jpg'/></p>" ] [ "[[image:lol.jpg]]" convert-farkup ] unit-test
[ "<p><img src='lol.jpg' alt='teh lol'/></p>" ] [ "[[image:lol.jpg|teh lol]]" convert-farkup ] unit-test
[ "<p><a href='http://lol.com'>http://lol.com</a></p>" ] [ "[[http://lol.com]]" convert-farkup ] unit-test
[ "<p><a href='http://lol.com'>haha</a></p>" ] [ "[[http://lol.com|haha]]" convert-farkup ] unit-test
[ "<p><a href='Foo/Bar'>Bar</a></p>" ] [ "[[Foo/Bar]]" convert-farkup ] unit-test

"/wiki/view/" relative-link-prefix [
    [ "<p><a href='/wiki/view/Foo/Bar'>Bar</a></p>" ] [ "[[Foo/Bar]]" convert-farkup ] unit-test
] with-variable

[ ] [ "[{}]" convert-farkup drop ] unit-test

[ "<pre>hello\n</pre>" ] [ "[{hello}]" convert-farkup ] unit-test

[
    "<p>Feature comparison:\n<table><tr><td>a</td><td>Factor</td><td>Java</td><td>Lisp</td></tr><tr><td>Coolness</td><td>Yes</td><td>No</td><td>No</td></tr><tr><td>Badass</td><td>Yes</td><td>No</td><td>No</td></tr><tr><td>Enterprise</td><td>Yes</td><td>Yes</td><td>No</td></tr><tr><td>Kosher</td><td>Yes</td><td>No</td><td>Yes</td></tr></table></p>"
] [ "Feature comparison:\n|a|Factor|Java|Lisp|\n|Coolness|Yes|No|No|\n|Badass|Yes|No|No|\n|Enterprise|Yes|Yes|No|\n|Kosher|Yes|No|Yes|\n" convert-farkup ] unit-test

[
    "<p>Feature comparison:\n</p><table><tr><td>a</td><td>Factor</td><td>Java</td><td>Lisp</td></tr><tr><td>Coolness</td><td>Yes</td><td>No</td><td>No</td></tr><tr><td>Badass</td><td>Yes</td><td>No</td><td>No</td></tr><tr><td>Enterprise</td><td>Yes</td><td>Yes</td><td>No</td></tr><tr><td>Kosher</td><td>Yes</td><td>No</td><td>Yes</td></tr></table>"
] [ "Feature comparison:\n\n|a|Factor|Java|Lisp|\n|Coolness|Yes|No|No|\n|Badass|Yes|No|No|\n|Enterprise|Yes|Yes|No|\n|Kosher|Yes|No|Yes|\n" convert-farkup ] unit-test

[
    "<p>This wiki is written in <a href='Factor'>Factor</a> and is hosted on a <a href='http://linode.com'>http://linode.com</a> virtual server.</p>"
] [
    "This wiki is written in [[Factor]] and is hosted on a [[http://linode.com|http://linode.com]] virtual server."
    convert-farkup
] unit-test

[ "<p><a href='a'>a</a> <a href='b'>c</a></p>" ] [ "[[a]] [[b|c]]" convert-farkup ] unit-test

[ "<p><a href='C%2b%2b'>C++</a></p>" ] [ "[[C++]]" convert-farkup ] unit-test

[ "<p>&lt;foo&gt;</p>" ] [ "<foo>" convert-farkup ] unit-test

[ "<p>asdf\n<ul><li>lol</li>\n<li>haha</li></ul></p>" ] [ "asdf\n-lol\n-haha" convert-farkup ] unit-test

[ "<p>asdf\n</p><ul><li>lol</li>\n<li>haha</li></ul>" ]
 [ "asdf\n\n-lol\n-haha" convert-farkup ] unit-test

[ "<hr/>" ] [ "___" convert-farkup ] unit-test
[ "<hr/>\n" ] [ "___\n" convert-farkup ] unit-test

[ "<p>before:\n<pre><span class='OPERATOR'>{</span> <span class='DIGIT'>1</span> <span class='DIGIT'>2</span> <span class='DIGIT'>3</span> <span class='OPERATOR'>}</span> <span class='DIGIT'>1</span> tail\n</pre></p>" ] 
[ "before:\n[factor{{ 1 2 3 } 1 tail}]" convert-farkup ] unit-test
 
[ "<p><a href='Factor'>Factor</a>-rific!</p>" ]
[ "[[Factor]]-rific!" convert-farkup ] unit-test

[ "<p>[ factor { 1 2 3 }]</p>" ]
[ "[ factor { 1 2 3 }]" convert-farkup ] unit-test

[ "<p>paragraph\n<hr/></p>" ]
[ "paragraph\n___" convert-farkup ] unit-test

[ "<p>paragraph\n a ___ b</p>" ]
[ "paragraph\n a ___ b" convert-farkup ] unit-test

[ "\n<ul><li> a</li>\n</ul><hr/>" ]
[ "\n- a\n___" convert-farkup ] unit-test

[ "<p>hello_world how are you today?\n<ul><li> hello_world how are you today?</li></ul></p>" ]
[ "hello_world how are you today?\n- hello_world how are you today?" convert-farkup ] unit-test

: check-link-escaping ( string -- link )
    convert-farkup string>xml-chunk
    "a" deep-tag-named "href" swap at url-decode ;

[ "Trader Joe's" ] [ "[[Trader Joe's]]" check-link-escaping ] unit-test
[ "<foo>" ] [ "[[<foo>]]" check-link-escaping ] unit-test
[ "&blah;" ] [ "[[&blah;]]" check-link-escaping ] unit-test
[ "C++" ] [ "[[C++]]" check-link-escaping ] unit-test