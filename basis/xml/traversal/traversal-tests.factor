! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: xml xml.traversal tools.test xml.data sequences arrays kernel ;

{ "bar" } [ "<foo>bar</foo>" string>xml children>string ] unit-test

{ "" } [ "<foo></foo>" string>xml children>string ] unit-test

{ "" } [ "<foo/>" string>xml children>string ] unit-test

{ "bar qux" } [ "<foo>bar <baz>qux</baz></foo>" string>xml deep-children>string ] unit-test

{ "blah" } [ "<foo attr='blah'/>" string>xml-chunk "foo" deep-tag-named "attr" attr ] unit-test

{ { "blah" } } [ "<foo attr='blah'/>" string>xml-chunk "foo" deep-tags-named [ "attr" attr ] map ] unit-test

{ "blah" } [ "<foo attr='blah'/>" string>xml "foo" deep-tag-named "attr" attr ] unit-test

{ { "blah" } } [ "<foo attr='blah'/>" string>xml "foo" deep-tags-named [ "attr" attr ] map ] unit-test

{ { "blah" } } [ "<foo><bar attr='blah'/></foo>" string>xml "blah" "attr" tags-with-attr [ "attr" attr ] map ] unit-test
{ { "blah" } } [ "bar" { { "attr" "blah" } } f <tag> 1array "blah" "attr" tags-with-attr [ "attr" attr ] map ] unit-test

{ { "https://hub.example.com" "https://alt.example.com" } } [ "<head><link rel='alternate' href='https://alt.example.com'/><link rel='hub' href='https://hub.example.com'/></head>" string>xml-chunk "head" tag-named [ "link" "hub" "rel" tag-named-with-attr ] [ "link" "alternate" "rel" tag-named-with-attr ] bi [ "href" attr ] bi@ 2array ] unit-test
