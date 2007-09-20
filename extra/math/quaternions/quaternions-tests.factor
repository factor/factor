IN: temporary
USING: tools.test math.quaternions kernel math.vectors
math.constants ;

[ 1 ] [ qi norm ] unit-test
[ 1 ] [ qj norm ] unit-test
[ 1 ] [ qk norm ] unit-test
[ 1 ] [ q1 norm ] unit-test
[ 0 ] [ q0 norm ] unit-test
[ t ] [ qi qj q* qk = ] unit-test
[ t ] [ qj qk q* qi = ] unit-test
[ t ] [ qk qi q* qj = ] unit-test
[ t ] [ qi qi q* q1 v+ q0 = ] unit-test
[ t ] [ qj qj q* q1 v+ q0 = ] unit-test
[ t ] [ qk qk q* q1 v+ q0 = ] unit-test
[ t ] [ qi qj qk q* q* q1 v+ q0 = ] unit-test
[ t ] [ i qj n*v qk = ] unit-test
[ t ] [ qj i q*n qk v+ q0 = ] unit-test
[ t ] [ qk qj q/ qi = ] unit-test
[ t ] [ qi qk q/ qj = ] unit-test
[ t ] [ qj qi q/ qk = ] unit-test
[ t ] [ qi q>v v>q qi = ] unit-test
[ t ] [ qj q>v v>q qj = ] unit-test
[ t ] [ qk q>v v>q qk = ] unit-test
[ t ] [ 1 c>q q1 = ] unit-test
[ t ] [ i c>q qi = ] unit-test
