USING: lazy-lists.examples lazy-lists tools.test ;
IN: lazy-lists.examples.tests

[ { 1 3 5 7 } ] [ 4 odds ltake list>array ] unit-test
[ { 0 1 4 9 16 } ] [ first-five-squares ] unit-test
