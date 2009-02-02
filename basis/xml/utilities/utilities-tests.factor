! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: xml xml.utilities tools.test xml.data sequences ;
IN: xml.utilities.tests

[ "bar" ] [ "<foo>bar</foo>" string>xml children>string ] unit-test

[ "" ] [ "<foo></foo>" string>xml children>string ] unit-test

[ "" ] [ "<foo/>" string>xml children>string ] unit-test

XML-NS: foo http://blah.com

[ T{ name { main "bling" } { url "http://blah.com" } } ] [ "bling" foo ] unit-test

[ "blah" ] [ "<foo attr='blah'/>" string>xml-chunk "foo" deep-tag-named "attr" attr ] unit-test

[ { "blah" } ] [ "<foo attr='blah'/>" string>xml-chunk "foo" deep-tags-named [ "attr" attr ] map ] unit-test

[ "blah" ] [ "<foo attr='blah'/>" string>xml "foo" deep-tag-named "attr" attr ] unit-test

[ { "blah" } ] [ "<foo attr='blah'/>" string>xml "foo" deep-tags-named [ "attr" attr ] map ] unit-test