USING: farkup kernel tools.test ;
IN: farkup.tests

[ "<ul><li>foo</li></ul>" ] [ "-foo" convert-farkup ] unit-test
[ "<ul><li>foo</li></ul>\n" ] [ "-foo\n" convert-farkup ] unit-test
[ "<ul><li>foo</li><li>bar</li></ul>" ] [ "-foo\n-bar" convert-farkup ] unit-test
[ "<ul><li>foo</li><li>bar</li></ul>\n" ] [ "-foo\n-bar\n" convert-farkup ] unit-test

[ "<ul><li>foo</li></ul>\n<p>bar\n</p>" ] [ "-foo\nbar\n" convert-farkup ] unit-test
[ "<p>*foo\nbar\n</p>" ] [ "*foo\nbar\n" convert-farkup ] unit-test
[ "<p><strong>Wow!</strong></p>" ] [ "*Wow!*" convert-farkup ] unit-test
[ "<p><em>Wow.</em></p>" ] [ "_Wow._" convert-farkup ] unit-test

[ "<p>*</p>" ] [ "*" convert-farkup ] unit-test
[ "<p>*</p>" ] [ "\\*" convert-farkup ] unit-test
[ "<p>**</p>" ] [ "\\**" convert-farkup ] unit-test

[ "" ] [ "\n\n" convert-farkup ] unit-test
[ "\n" ] [ "\n\n\n" convert-farkup ] unit-test
[ "<p>foo</p><p>bar</p>" ] [ "foo\n\nbar" convert-farkup ] unit-test

[ "\n<p>bar\n</p>" ] [ "\nbar\n" convert-farkup ] unit-test

[ "<p>foo</p>\n<p>bar</p>" ] [ "foo\n\n\nbar" convert-farkup ] unit-test

[ "" ] [ "" convert-farkup ] unit-test

[ "<p>|a</p>" ]
[ "|a" convert-farkup ] unit-test

[ "<p>|a|</p>" ]
[ "|a|" convert-farkup ] unit-test

[ "<table><tr><td>a</td><td>b</td></tr></table>" ]
[ "a|b" convert-farkup ] unit-test

[ "<table><tr><td>a</td><td>b</td></tr></table>\n<table><tr><td>c</td><td>d</td></tr></table>" ]
[ "a|b\nc|d" convert-farkup ] unit-test

[ "<table><tr><td>a</td><td>b</td></tr></table>\n<table><tr><td>c</td><td>d</td></tr></table>\n" ]
[ "a|b\nc|d\n" convert-farkup ] unit-test

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

[ "<span class='KEYWORD3'>int</span> <span class='FUNCTION'>main</span><span class='OPERATOR'>(</span><span class='OPERATOR'>)</span><br/>" ]
[ "[c{int main()}]" convert-farkup ] unit-test

[ "<p><img src=\"lol.jpg\"/></p>" ] [ "[[image:lol.jpg]]" convert-farkup ] unit-test
[ "<p><img src=\"lol.jpg\" alt=\"teh lol\"/></p>" ] [ "[[image:lol.jpg|teh lol]]" convert-farkup ] unit-test
[ "<p><a href=\"lol.com\"></a></p>" ] [ "[[lol.com]]" convert-farkup ] unit-test
[ "<p><a href=\"lol.com\">haha</a></p>" ] [ "[[lol.com|haha]]" convert-farkup ] unit-test
