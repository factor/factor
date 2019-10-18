IN: temporary
USE: kernel
USE: math
USE: test

! This caused the Java Factor to run out of memory
[ ] [ 100000 [ [ call ] callcc0 ] times ] unit-test
