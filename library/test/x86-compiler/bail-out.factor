IN: scratchpad
USE: combinators
USE: compiler
USE: errors
USE: logic
USE: math
USE: stack
USE: test

: cannot-compile call + ;

[ f ] [ [ \ cannot-compile compile ] [ not ] catch ] unit-test
[ f ] [ [ \ cannot-compile compile ] [ not ] catch ] unit-test

[ 4 ] [ [ 2 2 ] cannot-compile ] unit-test
