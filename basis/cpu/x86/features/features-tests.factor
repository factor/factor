USING: cpu.x86.features tools.test kernel sequences math math.order system ;
IN: cpu.x86.features.tests

cpu x86? [
    [ t ] [ sse-version 0 42 between? ] unit-test
    [ t ] [ [ 10000 [ ] times ] count-instructions integer? ] unit-test
] when
