USING: accessors assocs compiler.cfg compiler.cfg.instructions compiler.cfg.loop-detection
compiler.cfg.register-allocation.chordal.spilling.next-use
kernel locals namespaces tools.test ;
IN: compiler.cfg.register-allocation.chordal.spilling.next-use.tests

! Minimum distance across a diamond; a loop-exit route does not displace a
! nearer use within the loop. Neither operation mutates its source map.
{ H{ { 1 3 } { 2 8 } { 3 100002 } } } [
    H{ { 1 3 } { 2 8 } } clone
    H{ { 1 1 } { 3 2 } } loop-exit-distance pick merge-next-use!
] unit-test

{ H{ { 1 0 } { 2 0 } { 9 6 } } } [
    H{ { 3 2 } { 9 5 } }
    T{ ##add { dst 3 } { src1 1 } { src2 2 } } transfer-next-use
] unit-test

{ H{ { 9 6 } } } [
    H{ { 3 2 } { 9 5 } }
    T{ ##phi { dst 3 } { inputs H{ { 10 1 } { 11 2 } } } }
    transfer-next-use
] unit-test

! Distinct predecessor edges see distinct phi sources.
{ H{ { 1 0 } { 9 6 } } H{ { 2 0 } { 9 6 } } } [ [let
    T{ basic-block { instructions V{
        T{ ##phi { dst 3 } { inputs H{ { 10 1 } { 11 2 } } } }
    } } } :> join
    H{ } clone :> entries
    H{ { 9 6 } } join entries set-at
    10 join entries edge-next-use
    11 join entries edge-next-use
] ] unit-test

! Equal nesting depth does not make an edge stay inside the same loop.
{ 100000 0 } [
    H{
        { 1 T{ natural-loop { blocks HS{ 1 2 } } } }
        { 3 T{ natural-loop { blocks HS{ 3 4 } } } }
    } loops [ 2 3 loop-exit-penalty 1 2 loop-exit-penalty ] with-variable
] unit-test
