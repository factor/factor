IN: temporary
USE: kernel
USE: math
USE: test

[ 1 #{ 0 1 }# rect> ] unit-test-fails
[ #{ 0 1 }# 1 rect> ] unit-test-fails

[ f ] [ #{ 5 12.5 }# 5  = ] unit-test
[ t ] [ #{ 1.0 2.0 }# #{ 1 2 }#  = ] unit-test
[ f ] [ #{ 1.0 2.3 }# #{ 1 2 }#  = ] unit-test

[ #{ 2 5 }# ] [ 2 5  rect> ] unit-test
[ 2 5 ] [ #{ 2 5 }#  >rect ] unit-test
[ #{ 1/2 1 }# ] [ 1/2 i  + ] unit-test
[ #{ 1/2 1 }# ] [ i 1/2  + ] unit-test
[ t ] [ #{ 11 64 }# #{ 11 64 }#  = ] unit-test
[ #{ 2 1 }# ] [ 2 i  + ] unit-test
[ #{ 2 1 }# ] [ i 2  + ] unit-test
[ #{ 5 4 }# ] [ #{ 2 2 }# #{ 3 2 }#  + ] unit-test
[ 5 ] [ #{ 2 2 }# #{ 3 -2 }#  + ] unit-test
[ #{ 1.0 1 }# ] [ 1.0 i  + ] unit-test

[ #{ 1/2 -1 }# ] [ 1/2 i  - ] unit-test
[ #{ -1/2 1 }# ] [ i 1/2  - ] unit-test
[ #{ 1/3 1/4 }# ] [ 1 3 / 1 2 / i * + 1 4 / i *  - ] unit-test
[ #{ -1/3 -1/4 }# ] [ 1 4 / i * 1 3 / 1 2 / i * +  - ] unit-test
[ #{ 1/5 1/4 }# ] [ #{ 3/5 1/2 }# #{ 2/5 1/4 }#  - ] unit-test
[ 4 ] [ #{ 5 10/3 }# #{ 1 10/3 }#  - ] unit-test
[ #{ 1.0 -1 }# ] [ 1.0 i  - ] unit-test

[ #{ 0 1 }# ] [ i 1  * ] unit-test
[ #{ 0 1 }# ] [ 1 i  * ] unit-test
[ #{ 0 1.0 }# ] [ 1.0 i  * ] unit-test
[ -1 ] [ i i  * ] unit-test
[ #{ 0 1 }# ] [ 1 i  * ] unit-test
[ #{ 0 1 }# ] [ i 1  * ] unit-test
[ #{ 0 1/2 }# ] [ 1/2 i  * ] unit-test
[ #{ 0 1/2 }# ] [ i 1/2  * ] unit-test
[ 2 ] [ #{ 1 1 }# #{ 1 -1 }#  * ] unit-test
[ 1 ] [ i -i  * ] unit-test

[ -1 ] [ i -i  / ] unit-test
[ #{ 0 1 }# ] [ 1 -i  / ] unit-test
[ t ] [ #{ 12 13 }# #{ 13 14 }# / #{ 13 14 }# * #{ 12 13 }#  = ] unit-test

[ #{ -3 4 }# ] [ #{ 3 -4 }#  neg ] unit-test

[ 5 ] [ #{ 3 4 }# abs ] unit-test
[ 5 ] [ -5.0 abs ] unit-test

! Make sure arguments are sane
[ 0 ] [ 0 arg ] unit-test
[ 0 ] [ 1 arg ] unit-test
[ t ] [ -1 arg 3.14 3.15 between? ] unit-test
[ t ] [ i arg 1.57 1.58 between? ] unit-test
[ t ] [ -i arg -1.58 -1.57 between? ] unit-test

[ 1 0 ] [ 1 >polar ] unit-test
[ 1 ] [ -1 >polar drop ] unit-test
[ t ] [ -1 >polar nip 3.14 3.15 between? ] unit-test
