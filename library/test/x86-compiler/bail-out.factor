IN: scratchpad
USE: combinators
USE: compiler
USE: errors
USE: logic
USE: math
USE: stack
USE: test

: bail-out call + ;

[ f ] [ [ \ bail-out compile ] [ not ] catch ] unit-test
[ f ] [ [ \ bail-out compile ] [ not ] catch ] unit-test

[ 4 ] [ [ 2 2 ] bail-out ] unit-test
