IN: scratchpad
USE: arithmetic
USE: kernel
USE: math
USE: test

[ 4.0 ] [ 16 ] [ sqrt ] test-word
[ #{ 0 4.0 } ] [ -16 ] [ sqrt ] test-word

[ 4.0 ] [ 2 2 ] [ ^ ] test-word
[ 0.25 ] [ 2 -2 ] [ ^ ] test-word
[ t ] [ 2 0.5 ^ 2 ^ ] [ 2 2.00001 between? ] test-word
[ t ] [ e pi i * ^ real ] [ -1.0 = ] test-word
[ t ] [ e pi i * ^ imaginary ] [ -0.00001 0.00001 between? ] test-word

[ 1.0 ] [ 0 ] [ cosh ] test-word
[ 0.0 ] [ 1 ] [ acosh ] test-word

[ 1.0 ] [ 0 ] [ cos ] test-word
[ 0.0 ] [ 1 ] [ acos ] test-word

[ 0.0 ] [ 0 ] [ sinh ] test-word
[ 0.0 ] [ 0 ] [ asinh ] test-word

[ 0.0 ] [ 0 ] [ sin ] test-word
[ 0.0 ] [ 0 ] [ asin ] test-word
