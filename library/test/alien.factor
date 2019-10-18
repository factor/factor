IN: scratchpad
USE: alien
USE: kernel
USE: test
USE: inference

[ t ] [ 0 <alien> 0 <alien> = ] unit-test
[ f ] [ 0 <alien> local-alien? ] unit-test
[ f ] [ 0 <alien> 1024 <local-alien> = ] unit-test
[ f ] [ 0 <alien> 1024 <alien> = ] unit-test
[ f ] [ "hello" 1024 <alien> = ] unit-test
[ t ] [ 1024 <local-alien> local-alien? ] unit-test

! : alien-inference-1
!     "void" "foobar" "boo" [ "short" "short" ] alien-invoke ;
! 
! [ [[ 2 0 ]] ] [ [ alien-inference-1 ] infer old-effect ] unit-test
! 
! : alien-inference-2
!     "int" "foobar" "boo" [ "short" "short" ] alien-invoke ;
! 
! [ [[ 2 1 ]] ] [ [ alien-inference-2 ] infer old-effect ] unit-test
