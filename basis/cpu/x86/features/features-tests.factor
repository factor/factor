USING: cpu.x86.features tools.test kernel sequences math math.order
strings system io.binary ;
IN: cpu.x86.features.tests

[ t ] [ sse-version 0 42 between? ] unit-test
[ t ] [ [ 10000 [ ] times ] count-instructions integer? ] unit-test

{ "GenuineIntel" }
[ 0 cpuid [ 4 >le ] map { 1 3 2 } swap nths concat >string ] unit-test
