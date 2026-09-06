USING: kernel math math.order tools.test ;

{ +lt+ } [ "ab" "abc" <=> ] unit-test
{ +gt+ } [ "abc" "ab" <=> ] unit-test
{ +lt+ } [ 3 4 <=> ] unit-test
{ +eq+ } [ 4 4 <=> ] unit-test
{ +gt+ } [ 4 3 <=> ] unit-test

{ 20 } [ 20 0 100 clamp ] unit-test
{ 0 } [ -20 0 100 clamp ] unit-test
{ 100 } [ 120 0 100 clamp ] unit-test

! Both key quotations see the caller's row, not the first computed key.
{ 12 +lt+ } [ 10 3 4 [ [ 1 + ] dip sq ] compare ] unit-test
{ 12 +gt+ } [ 10 4 3 [ [ 1 + ] dip sq ] compare ] unit-test
{ 12 +eq+ } [ 10 3 3 [ [ 1 + ] dip sq ] compare ] unit-test
