USING: tools.test state-parser kernel io strings ;

[ "hello" ] [ "hello" [ rest ] string-parse ] unit-test
[ 2 4 ] [ "12\n123" [ rest drop get-line get-column ] string-parse ] unit-test
[ "hi" " how are you?" ] [ "hi how are you?" [ [ get-char blank? ] take-until rest ] string-parse ] unit-test
[ "foo" ";bar" ] [ "foo;bar" [ CHAR: ; take-char rest ] string-parse ] unit-test
[ "foo " " bar" ] [ "foo and bar" [ "and" take-string rest ] string-parse ] unit-test
[ "baz" ] [ " \n\t baz" [ pass-blank rest ] string-parse ] unit-test
