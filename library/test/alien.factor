IN: scratchpad
USE: alien
USE: kernel
USE: test

[ t ] [ 0 <alien> 0 <alien> = ] unit-test
[ f ] [ 0 <alien> local-alien? ] unit-test
[ t ] [ 1024 <local-alien> local-alien? ] unit-test
