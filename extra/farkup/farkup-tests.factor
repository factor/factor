USING: farkup kernel tools.test ;
IN: temporary

[ "<ul><li>foo</li></ul>" ] [ "-foo" parse-farkup ] unit-test
[ "<ul><li>foo</li></ul>\n" ] [ "-foo\n" parse-farkup ] unit-test
[ "<ul><li>foo</li><li>bar</li></ul>" ] [ "-foo\n-bar" parse-farkup ] unit-test
[ "<ul><li>foo</li><li>bar</li></ul>\n" ] [ "-foo\n-bar\n" parse-farkup ] unit-test

[ "<ul><li>foo</li></ul>\n<p>bar\n</p>" ] [ "-foo\nbar\n" parse-farkup ] unit-test
[ "<p>*foo\nbar\n</p>" ] [ "*foo\nbar\n" parse-farkup ] unit-test
[ "<p><strong>Wow!</strong></p>" ] [ "*Wow!*" parse-farkup ] unit-test
[ "<p><em>Wow.</em></p>" ] [ "_Wow._" parse-farkup ] unit-test

[ "<p>*</p>" ] [ "*" parse-farkup ] unit-test
[ "<p>*</p>" ] [ "\\*" parse-farkup ] unit-test
[ "<p>**</p>" ] [ "\\**" parse-farkup ] unit-test

[ "" ] [ "\n\n" parse-farkup ] unit-test
[ "\n" ] [ "\n\n\n" parse-farkup ] unit-test
[ "<p>foo</p><p>bar</p>" ] [ "foo\n\nbar" parse-farkup ] unit-test

[ "\n<p>bar\n</p>" ] [ "\nbar\n" parse-farkup ] unit-test

[ "<p>foo</p>\n<p>bar</p>" ] [ "foo\n\n\nbar" parse-farkup ] unit-test

[ "" ] [ "" parse-farkup ] unit-test

[ "<p>|a</p>" ]
[ "|a" parse-farkup ] unit-test

[ "<p>|a|</p>" ]
[ "|a|" parse-farkup ] unit-test

[ "<table><tr><td>a</td><td>b</td></tr></table>" ]
[ "a|b" parse-farkup ] unit-test

[ "<table><tr><td>a</td><td>b</td></tr></table>\n<table><tr><td>c</td><td>d</td></tr></table>" ]
[ "a|b\nc|d" parse-farkup ] unit-test

[ "<table><tr><td>a</td><td>b</td></tr></table>\n<table><tr><td>c</td><td>d</td></tr></table>\n" ]
[ "a|b\nc|d\n" parse-farkup ] unit-test

