IN: scratchpad

USE: namespaces
USE: test
USE: threads

! This only tests co-operative threads in CFactor.

3 "x" set
[ yield 2 "x" set ] in-thread
[ 2 ] [ yield "x" get ] unit-test
