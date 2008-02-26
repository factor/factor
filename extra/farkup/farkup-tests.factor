USING: farkup kernel tools.test ;
IN: temporary

[ "<ul><li>foo</li></ul>" ] [ "-foo" parse-farkup ] unit-test
[ "<ul><li>foo</li></ul>" ] [ "-foo\n" parse-farkup ] unit-test
[ "<ul><li>foo</li><li>bar</li></ul>" ] [ "-foo\n-bar" parse-farkup ] unit-test
[ "<ul><li>foo</li><li>bar</li></ul>" ] [ "-foo\n-bar\n" parse-farkup ] unit-test

[ "<ul><li>foo</li></ul><p>bar</p>" ] [ "-foo\nbar\n" parse-farkup ] unit-test
[ "*foo\nbar\n" parse-farkup ] must-fail
[ "<p><strong>Wow!</strong></p>" ] [ "*Wow!*" parse-farkup ] unit-test
[ "<p><em>Wow.</em></p>" ] [ "_Wow._" parse-farkup ] unit-test
