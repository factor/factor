IN: cpu.x86.features.tests
USING: cpu.x86.features tools.test kernel sequences math system ;

cpu x86? [
    [ t ] [ sse2? { t f } member? ] unit-test
    [ t ] [ [ 10000 [ ] times ] count-instructions integer? ] unit-test
] when