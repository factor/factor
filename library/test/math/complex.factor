IN: scratchpad
USE: kernel
USE: math
USE: stack
USE: test

[ f ] [ #{ 5 12.5 } 5 ] [ = ] test-word
[ t ] [ #{ 1.0 2.0 } #{ 1 2 } ] [ = ] test-word
[ f ] [ #{ 1.0 2.3 } #{ 1 2 } ] [ = ] test-word

[ #{ 2 5 } ] [ 2 5 ] [ rect> ] test-word
[ 2 5 ] [ #{ 2 5 } ] [ >rect ] test-word
[ #{ 1/2 1 } ] [ 1/2 i ] [ + ] test-word
[ #{ 1/2 1 } ] [ i 1/2 ] [ + ] test-word
[ t ] [ #{ 11 64 } #{ 11 64 } ] [ = ] test-word
[ #{ 2 1 } ] [ 2 i ] [ + ] test-word
[ #{ 2 1 } ] [ i 2 ] [ + ] test-word
[ #{ 5 4 } ] [ #{ 2 2 } #{ 3 2 } ] [ + ] test-word
[ 5 ] [ #{ 2 2 } #{ 3 -2 } ] [ + ] test-word
[ #{ 1.0 1 } ] [ 1.0 i ] [ + ] test-word

[ #{ 1/2 -1 } ] [ 1/2 i ] [ - ] test-word
[ #{ -1/2 1 } ] [ i 1/2 ] [ - ] test-word
[ #{ 1/3 1/4 } ] [ 1 3 / 1 2 / i * + 1 4 / i * ] [ - ] test-word
[ #{ -1/3 -1/4 } ] [ 1 4 / i * 1 3 / 1 2 / i * + ] [ - ] test-word
[ #{ 1/5 1/4 } ] [ #{ 3/5 1/2 } #{ 2/5 1/4 } ] [ - ] test-word
[ 4 ] [ #{ 5 10/3 } #{ 1 10/3 } ] [ - ] test-word
[ #{ 1.0 -1 } ] [ 1.0 i ] [ - ] test-word

[ #{ 0 1 } ] [ i 1 ] [ * ] test-word
[ #{ 0 1 } ] [ 1 i ] [ * ] test-word
[ #{ 0 1.0 } ] [ 1.0 i ] [ * ] test-word
[ -1 ] [ i i ] [ * ] test-word
[ #{ 0 1 } ] [ 1 i ] [ * ] test-word
[ #{ 0 1 } ] [ i 1 ] [ * ] test-word
[ #{ 0 1/2 } ] [ 1/2 i ] [ * ] test-word
[ #{ 0 1/2 } ] [ i 1/2 ] [ * ] test-word
[ 2 ] [ #{ 1 1 } #{ 1 -1 } ] [ * ] test-word
[ 1 ] [ i -i ] [ * ] test-word

[ -1 ] [ i -i ] [ / ] test-word
[ #{ 0 1 } ] [ 1 -i ] [ / ] test-word
[ t ] [ #{ 12 13 } #{ 13 14 } / #{ 13 14 } * #{ 12 13 } ] [ = ] test-word

[ #{ -3 4 } ] [ #{ 3 -4 } ] [ neg ] test-word

[ 5 ] [ #{ 3 4 } abs ] unit-test
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
