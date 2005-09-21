IN: temporary
USE: compiler
USE: errors
USE: math
USE: test
USE: kernel

: bail-out call + ;

[ f ] [ [ \ bail-out compile ] catch not ] unit-test
[ f ] [ [ \ bail-out compile ] catch not ] unit-test

[ 4 ] [ [ 2 2 ] bail-out ] unit-test
