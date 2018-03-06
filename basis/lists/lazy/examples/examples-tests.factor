USING: lists.lazy.examples lists.lazy lists tools.test ;

{ { 1 3 5 7 } } [ 4 odds ltake list>array ] unit-test
{ { 0 1 4 9 16 } } [ first-five-squares ] unit-test
