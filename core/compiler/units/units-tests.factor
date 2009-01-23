IN: compiler.units.tests
USING: definitions compiler.units tools.test arrays sequences words kernel
accessors ;

[ flushed-dependency ] [ f flushed-dependency strongest-dependency ] unit-test
[ flushed-dependency ] [ flushed-dependency f strongest-dependency ] unit-test
[ inlined-dependency ] [ flushed-dependency inlined-dependency strongest-dependency ] unit-test
[ inlined-dependency ] [ called-dependency inlined-dependency strongest-dependency ] unit-test
[ flushed-dependency ] [ called-dependency flushed-dependency strongest-dependency ] unit-test
[ called-dependency ] [ called-dependency f strongest-dependency ] unit-test

! Non-optimizing compiler bug
[ 1 1 ] [
    "A" "B" <word> [ [ 1 ] dip ] >>def dup f 2array 1array f modify-code-heap
    1 swap execute
] unit-test