IN: temporary
USING: effects tools.test ;

[ t ] [ 1 1 <effect> 2 2 <effect> effect<= ] unit-test
[ f ] [ 1 0 <effect> 2 2 <effect> effect<= ] unit-test
[ t ] [ 2 2 <effect> 2 2 <effect> effect<= ] unit-test
[ f ] [ 3 3 <effect> 2 2 <effect> effect<= ] unit-test
[ f ] [ 2 3 <effect> 2 2 <effect> effect<= ] unit-test
[ t ] [ 2 3 <effect> f effect<= ] unit-test
