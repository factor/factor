IN: scratchpad

USE: namespaces
USE: stdio
USE: test
USE: threads

! This only tests co-operative threads in CFactor.
! It won't give intended results in Java (or in CFactor if
! we ever get preemptive threads).

3 "x" set
[ yield 2 "x" set ] in-thread
[ 2 ] [ yield "x" get ] unit-test

! [ flush ] in-thread flush
