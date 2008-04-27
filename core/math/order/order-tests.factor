USING: kernel math.order tools.test ;
IN: math.order.tests

[ -1 ] [ "ab" "abc" <=> ] unit-test
[ 1 ] [ "abc" "ab" <=> ] unit-test

