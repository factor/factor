USING: multiline tools.test ;

STRING: test-it
foo
bar

;

[ "foo\nbar\n" ] [ test-it ] unit-test
[ "foo\nbar\n" ] [ <" foo
bar
 "> ] unit-test
