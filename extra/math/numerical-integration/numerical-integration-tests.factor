USING: kernel math.numerical-integration tools.test math
math.constants math.functions ;

{ 50 } [ 0 10 [ ] integrate-simpson ] unit-test
{ 1000/3 } [ 0 10 [ sq ] integrate-simpson ] unit-test
{ t } [ 0 pi 2 / [ sin ] integrate-simpson 1 .000000001 ~abs ] unit-test
{ t } [ 0 pi [ sin ] integrate-simpson 2 .00000001 ~abs ] unit-test
{ t } [  0 pi 2 * [ sin ] integrate-simpson 0 .00000000001 ~abs ] unit-test
