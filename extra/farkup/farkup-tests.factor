USING: farkup kernel tools.test ;
IN: temporary

[ "<ul><li>foo</li></ul>" ] [ "-foo" parse-farkup ] unit-test
[ "<ul><li>foo</li></ul>\n" ] [ "-foo\n" parse-farkup ] unit-test
[ "<ul><li>foo</li><li>bar</li></ul>" ] [ "-foo\n-bar" parse-farkup ] unit-test
[ "<ul><li>foo</li><li>bar</li></ul>\n" ] [ "-foo\n-bar\n" parse-farkup ] unit-test

[ "<ul><li>foo</li></ul><p>\nbar\n</p>" ] [ "-foo\nbar\n" parse-farkup ] unit-test
[ "<p>*foo\nbar\n</p>" ] [ "*foo\nbar\n" parse-farkup ] unit-test
[ "<p><strong>Wow!</strong></p>" ] [ "*Wow!*" parse-farkup ] unit-test
[ "<p><em>Wow.</em></p>" ] [ "_Wow._" parse-farkup ] unit-test

[ "<p>*</p>" ] [ "*" parse-farkup ] unit-test
[ "<p>*</p>" ] [ "\\*" parse-farkup ] unit-test
[ "<p>**</p>" ] [ "\\**" parse-farkup ] unit-test
