USING: multiline tools.test ;
IN: multiline.tests

STRING: test-it
foo
bar

;

[ "foo\nbar\n" ] [ test-it ] unit-test
[ "foo\nbar\n" ] [ <" foo
bar
"> ] unit-test

[ "hello\nworld" ] [ <" hello
world"> ] unit-test

[ "hello" "world" ] [ <" hello"> <" world"> ] unit-test

[ "\nhi" ] [ <"
hi"> ] unit-test
