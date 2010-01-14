! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: classes.struct.bit-accessors tools.test effects kernel
sequences random stack-checker ;
IN: classes.struct.bit-accessors.test

[ t ] [ 20 iota random 20 iota random bit-reader infer (( alien -- n )) effect= ] unit-test
[ t ] [ 20 iota random 20 iota random bit-writer infer (( n alien -- )) effect= ] unit-test
