! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: farkup kernel peg peg.ebnf tools.test ;
IN: farkup.tests

[ ] [
    "abcd-*strong*\nasdifj\nweouh23ouh23"
    "paragraph" \ farkup rule parse drop
] unit-test

[ ] [
    "abcd-*strong*\nasdifj\nweouh23ouh23\n"
    "paragraph" \ farkup rule parse drop
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


[ "\n\n" ] [ "\n\n" convert-farkup ] unit-test
[ "\n\n" ] [ "\r\n\r\n" convert-farkup ] unit-test
[ "\n\n\n\n" ] [ "\r\r\r\r" convert-farkup ] unit-test
[ "\n\n\n" ] [ "\r\r\r" convert-farkup ] unit-test
[ "\n\n\n" ] [ "\n\n\n" convert-farkup ] unit-test
[ "<p>foo</p><p>bar</p>" ] [ "foo\n\nbar" convert-farkup ] unit-test
[ "<p>foo</p><p>bar</p>" ] [ "foo\r\n\r\nbar" convert-farkup ] unit-test
[ "<p>foo</p><p>bar</p>" ] [ "foo\r\rbar" convert-farkup ] unit-test
[ "<p>foo</p><p>bar</p>" ] [ "foo\r\r\nbar" convert-farkup ] unit-test

[ "\n<p>bar\n</p>" ] [ "\nbar\n" convert-farkup ] unit-test
[ "\n<p>bar\n</p>" ] [ "\rbar\r" convert-farkup ] unit-test
[ "\n<p>bar\n</p>" ] [ "\r\nbar\r\n" convert-farkup ] unit-test

[ "<p>foo</p><p>bar</p>" ] [ "foo\n\n\nbar" convert-farkup ] unit-test

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

[ "<p><img src=\"lol.jpg\"/></p>" ] [ "[[image:lol.jpg]]" convert-farkup ] unit-test
[ "<p><img src=\"lol.jpg\" alt=\"teh lol\"/></p>" ] [ "[[image:lol.jpg|teh lol]]" convert-farkup ] unit-test
[ "<p><a href=\"lol.com\">lol.com</a></p>" ] [ "[[lol.com]]" convert-farkup ] unit-test
[ "<p><a href=\"lol.com\">haha</a></p>" ] [ "[[lol.com|haha]]" convert-farkup ] unit-test

[ ] [ "[{}]" convert-farkup drop ] unit-test

[
    "<p>Feature comparison:\n<table><tr><td>a</td><td>Factor</td><td>Java</td><td>Lisp</td></tr><tr><td>Coolness</td><td>Yes</td><td>No</td><td>No</td></tr><tr><td>Badass</td><td>Yes</td><td>No</td><td>No</td></tr><tr><td>Enterprise</td><td>Yes</td><td>Yes</td><td>No</td></tr><tr><td>Kosher</td><td>Yes</td><td>No</td><td>Yes</td></tr></table></p>"
] [ "Feature comparison:\n|a|Factor|Java|Lisp|\n|Coolness|Yes|No|No|\n|Badass|Yes|No|No|\n|Enterprise|Yes|Yes|No|\n|Kosher|Yes|No|Yes|\n" convert-farkup ] unit-test

[
    "<p>Feature comparison:</p><table><tr><td>a</td><td>Factor</td><td>Java</td><td>Lisp</td></tr><tr><td>Coolness</td><td>Yes</td><td>No</td><td>No</td></tr><tr><td>Badass</td><td>Yes</td><td>No</td><td>No</td></tr><tr><td>Enterprise</td><td>Yes</td><td>Yes</td><td>No</td></tr><tr><td>Kosher</td><td>Yes</td><td>No</td><td>Yes</td></tr></table>"
] [ "Feature comparison:\n\n|a|Factor|Java|Lisp|\n|Coolness|Yes|No|No|\n|Badass|Yes|No|No|\n|Enterprise|Yes|Yes|No|\n|Kosher|Yes|No|Yes|\n" convert-farkup ] unit-test
