USING: kernel semantic-db tangle.html tools.test ;
IN: tangle.html.tests

[ "test" ] [ "test" >html ] unit-test
[ "<ul><li>An Item</li></ul>" ] [ { "An Item" } <ulist> >html ] unit-test
[ "<ul><li>One</li><li>Two</li><li>Three, ah ah ah</li></ul>" ] [ { "One" "Two" "Three, ah ah ah" } <ulist> >html ] unit-test
[ "<a href='foo/bar'>some link</a>" ] [ "foo/bar" "some link" <link> >html ] unit-test
