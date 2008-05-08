USING: kernel math.order tools.test ;
IN: math.order.tests

[ +lt+ ] [ "ab" "abc" <=> ] unit-test
[ +gt+ ] [ "abc" "ab" <=> ] unit-test
[ +lt+ ] [ 3 4 <=> ] unit-test
[ +eq+ ] [ 4 4 <=> ] unit-test
[ +gt+ ] [ 4 3 <=> ] unit-test

