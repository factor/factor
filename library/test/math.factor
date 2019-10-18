IN: scratchpad
USE: arithmetic
USE: compiler
USE: kernel
USE: math
USE: stdio
USE: test

"Testing math words." print

[ 100 ] [ 100 100 ] [ gcd ] test-word
[ 100 ] [ 1000 100 ] [ gcd ] test-word
[ 100 ] [ 100 1000 ] [ gcd ] test-word
[ 4 ] [ 132 64 ] [ gcd ] test-word
[ 4 ] [ -132 64 ] [ gcd ] test-word
[ 4 ] [ -132 -64 ] [ gcd ] test-word
[ 4 ] [ 132 -64 ] [ gcd ] test-word
[ 4 ] [ -132 -64 ] [ gcd ] test-word

! Some ratio tests.

[ t ] [ 10 3 ] [ / ratio? ] test-word
[ f ] [ 10 2 ] [ / ratio? ] test-word
[ 10 ] [ 10 ] [ numerator ] test-word
[ 1 ] [ 10 ] [ denominator ] test-word
[ 12 ] [ -12 -13 ] [ / numerator ] test-word
[ 13 ] [ -12 -13 ] [ / denominator ] test-word
[ 1 ] [ -1 -1 ] [ / numerator ] test-word
[ 1 ] [ -1 -1 ] [ / denominator ] test-word

[ -1 ] [ 2 -2 ] [ / ] test-word
[ -1 ] [ -2 2 ] [ / ] test-word

! Make sure computation results are sane types.

[ t ] [ 1 3 / 1 3 / ] [ = ] test-word
[ t ] [ 30 2^ ] [ fixnum? ] test-word
[ t ] [ 32 2^ ] [ bignum? ] test-word

[ -1 ] [ 1 ] [ neg ] test-word
[ 2.1 ] [ -2.1 ] [ neg ] test-word

! Make sure equality testing works.

[ t ] [ 1 1.0 ] [ = ] test-word
[ f ] [ #{ 5 12.5 } 5 ] [ = ] test-word
[ t ] [ #{ 1.0 2.0 } #{ 1 2 } ] [ = ] test-word
[ f ] [ #{ 1.0 2.3 } #{ 1 2 } ] [ = ] test-word

! Complex number tests.

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

! Comparison tests; make sure we're doing appropriate
! comparisons based on operand types.

! bignum -vs- bignum

[ t ]
[ 100000000000000000000000000 100000000000000000000000000 ]
[ = ]
test-word

[ f ]
[ 100000000000000000000000000 100000000000000000000000001 ]
[ = ]
test-word

[ t ]
[ 100000000000000000000000000 100000000000000000000000001 ]
[ < ]
test-word

[ t ]
[ 100000000000000000000000000 100000000000000000000000001 ]
[ <= ]
test-word

[ f ]
[ 100000000000000000000000000 100000000000000000000000001 ]
[ > ]
test-word

[ t ]
[ 100000000000000000000000002 100000000000000000000000001 ]
[ > ]
test-word

[ t ]
[ 100000000000000000000000002 100000000000000000000000001 ]
[ >= ]
test-word

[ f ]
[ 100000000000000000000000002 100000000000000000000000001 ]
[ < ]
test-word

! bignum -vs- fixnum

[ t ]
[ 100000000000000000000000000 1000 ]
[ >= ]
test-word

[ f ]
[ 100000000000000000000000000 1000 ]
[ < ]
test-word

! fixnum -vs- bignum

[ f ]
[ 1000 100000000000000000000000000 ]
[ >= ]
test-word

[ t ]
[ 1000 100000000000000000000000000 ]
[ < ]
test-word

! fixnum -vs- ratio

[ t ]
[ 1000000000/999999 1000 ]
[ > ]
test-word

! ratio -vs- fixnum

[ f ]
[ 100000 100000000000/999999 ]
[ > ]
test-word

! ratio -vs- ratio

[ t ]
[ 1000000000000/999999999999 1000000000001/999999999998 ]
[ < ]
test-word

! float -vs- fixnum

[ t ]
[ pi 3 ]
[ > ]
test-word

! fixnum -vs- float

[ f ]
[ e 2 ]
[ <= ]
test-word

! Test irrationals.

[ [ 1 1 0 0 ] ] [ [ sqrt ] ] [ balance>list ] test-word
[ 4.0 ] [ 16 ] [ sqrt ] test-word
[ #{ 0 4.0 } ] [ -16 ] [ sqrt ] test-word

[ [ 2 1 0 0 ] ] [ [ ^ ] ] [ balance>list ] test-word
[ 4.0 ] [ 2 2 ] [ ^ ] test-word
[ 0.25 ] [ 2 -2 ] [ ^ ] test-word
[ t ] [ 2 0.5 ^ 2 ^ ] [ 2 2.00001 between? ] test-word
[ t ] [ e pi i * ^ real ] [ -1.0 = ] test-word
[ t ] [ e pi i * ^ imaginary ] [ -0.00001 0.00001 between? ] test-word

[ [ 1 1 0 0 ] ] [ [ cosh ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ acosh ] ] [ balance>list ] test-word
[ 1.0 ] [ 0 ] [ cosh ] test-word
[ 0.0 ] [ 1 ] [ acosh ] test-word

[ [ 1 1 0 0 ] ] [ [ cos ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ acos ] ] [ balance>list ] test-word
[ 1.0 ] [ 0 ] [ cos ] test-word
[ 0.0 ] [ 1 ] [ acos ] test-word

[ [ 1 1 0 0 ] ] [ [ sinh ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ asinh ] ] [ balance>list ] test-word
[ 0.0 ] [ 0 ] [ sinh ] test-word
[ 0.0 ] [ 0 ] [ asinh ] test-word

[ [ 1 1 0 0 ] ] [ [ sin ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ asin ] ] [ balance>list ] test-word
[ 0.0 ] [ 0 ] [ sin ] test-word
[ 0.0 ] [ 0 ] [ asin ] test-word

! Make sure shift< is doing bignum upgrading.

[ 4294967296 ]
[ 1 32 ]
[ shift< ]
test-word

[ 18446744073709551616 ]
[ 1 64 ]
[ shift< ]
test-word

[ 340282366920938463463374607431768211456 ]
[ 1 128 ]
[ shift< ]
test-word

"Math tests done." print
