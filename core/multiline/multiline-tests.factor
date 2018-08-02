USING: eval multiline sequences tools.test ;
IN: multiline.tests

CONSTANT: test-it [[foo
bar
]]

{ "foo\nbar\n" } [ test-it ] unit-test
