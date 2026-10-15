USING: kernel math math.intervals math.intervals.bounds tools.test ;
IN: math.intervals.bounds.tests

{ t } [ 0 [a,inf] interval-nonnegative? ] unit-test
{ t } [ 0 [-inf,b] interval-nonpositive? ] unit-test
{ t } [
    -100 100 [a,b] 10 [a,a] assume> integral-closure 11 100 [a,b] =
] unit-test
{ t } [ 3 [a,inf] 2 [a,a] interval+ 5 [a,inf] = ] unit-test
{ t } [ 3 [a,inf] -2 [a,a] interval* -6 [-inf,b] = ] unit-test
{ t } [ 3 [a,inf] 0 [a,a] interval* 0 [a,a] = ] unit-test
{ t } [ full-interval interval-abs 0 [a,inf] = ] unit-test
{ t } [ 3 [a,inf] -3 [-inf,b] interval-union full-interval? ] unit-test
{ t } [
    0x100000000000000000000 [a,inf]
    0x100000000000000000001 swap interval-contains?
] unit-test
{ t } [ 1/3 2/3 [a,b] 2/3 [a,a] interval+ 1 4/3 [a,b] = ] unit-test
