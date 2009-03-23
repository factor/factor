USING: kernel math math.functions tools.test math.analysis
math.constants ;
IN: math.analysis.tests

CONSTANT: eps .00000001

[ t ] [ -9000000000000000000000000000000000000000000 gamma 1/0. = ] unit-test
[ t ] [ -1.5 gamma 2.363271801207344 eps ~ ] unit-test
[ t ] [ -1 gamma 1/0. = ] unit-test
[ t ] [ -0.5 gamma -3.544907701811 eps ~ ] unit-test
[ t ] [ 0 gamma 1/0. = ] unit-test
[ t ] [ .5 gamma 1.772453850905479 eps ~ ] unit-test
[ t ] [ 1 gamma 1 eps ~ ] unit-test
[ t ] [ 2 gamma 1 eps ~ ] unit-test
[ t ] [ 3 gamma 2 eps ~ ] unit-test
[ t ] [ 11 gamma 3628800.000015679 eps ~ ] unit-test
[ t ] [ 90000000000000000000000000000000000000000000 gamma 1/0. = ] unit-test
! some fun identities
[ t ] [ 2/3 gamma 2 pi * 3 sqrt 1/3 gamma * / eps ~ ] unit-test
[ t ] [ 3/4 gamma 2 sqrt pi * 1/4 gamma / eps ~ ] unit-test
[ t ] [ 4/5 gamma 2 5 sqrt / 2 + sqrt pi * 1/5 gamma / eps ~ ] unit-test
[ t ] [ 3/5 gamma 2 2 5 sqrt / - sqrt pi * 2/5 gamma / eps ~ ] unit-test
[ t ] [ -90000000000000000000000000000000000000000000 gammaln 1/0. = ] unit-test
[ t ] [ -1.5 gammaln 1/0. = ] unit-test
[ t ] [ -1 gammaln 1/0. = ] unit-test
[ t ] [ -0.5 gammaln 1/0. = ] unit-test
! [ t ] [ 0 gammaln 1/0. = ] unit-test
[ t ] [ .5 gammaln 0.572364942924679 eps ~ ] unit-test
[ t ] [ 1 gammaln 0 eps ~ ] unit-test
[ t ] [ 2 gammaln 1.110223024625157e-16 eps ~ ] unit-test
[ t ] [ 3 gammaln 0.6931471805599456 eps ~ ] unit-test
[ t ] [ 11 gammaln 15.10441257307984 eps ~ ] unit-test
[ t ] [ 9000000000000000000000000000000000000000000 gammaln 8.811521863477754e+44 eps ~ ] unit-test

