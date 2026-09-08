USING: accessors assocs compiler.cfg compiler.cfg.checker
compiler.cfg.instructions compiler.cfg.registers compiler.cfg.predecessors compiler.cfg.utilities compiler.test
cpu.architecture kernel namespaces sequences tools.test ;
IN: compiler.cfg.checker.tests

: fresh-bb ( insns n -- )
    [ [ clone dup ##phi? [ [ clone ] change-inputs ] when ] map ] dip test-bb ;

: diamond ( -- cfg )
    V{ T{ ##peek { dst 0 } { loc D: 0 } } T{ ##branch } } 0 fresh-bb
    V{ T{ ##load-integer { dst 1 } { val 1 } } T{ ##branch } } 1 fresh-bb
    V{ T{ ##load-integer { dst 2 } { val 2 } } T{ ##branch } } 2 fresh-bb
    V{
        T{ ##phi { dst 3 } { inputs H{ { 1 1 } { 2 2 } } } }
        T{ ##copy { dst 4 } { src 3 } { rep any-rep } }
        T{ ##branch }
    } 3 fresh-bb
    0 { 1 2 } edges 1 3 edge 2 3 edge
    0 get block>cfg ;

{ } [ diamond check-ssa ] unit-test

[ diamond 3 get instructions>> reverse! drop check-ssa ]
[ misplaced-phi? ] must-fail-with

[ diamond 3 get instructions>> first inputs>> 1 get swap delete-at check-ssa ]
[ bad-phi-inputs? ] must-fail-with

[ diamond 3 get instructions>> second 1 >>src drop check-ssa ]
[ non-dominating-ssa-use? ] must-fail-with

[ diamond 3 get instructions>> second 99 >>src drop check-ssa ]
[ undefined-ssa-use? ] must-fail-with

[ diamond 3 get instructions>> second 3 >>dst drop check-ssa ]
[ duplicate-ssa-definition? ] must-fail-with

! A phi use belongs to its incoming edge, not to the merge block.
[ diamond 3 get instructions>> first inputs>> 2 1 get rot set-at check-ssa ]
[ non-dominating-ssa-use? ] must-fail-with

! A valid cached predecessor list must agree in both directions.
[ diamond dup needs-predecessors 0 get 3 get predecessors>> push check-ssa ]
[ bad-predecessors? ] must-fail-with

! Check the original phi mapping before predecessor repair can hide it.
[ diamond 1 get V{ } clone >>successors drop check-ssa ]
[ bad-phi-inputs? ] must-fail-with

! Loop-carried definitions dominate the back edge, not the header.
{ } [
    V{ T{ ##load-integer { dst 0 } { val 0 } } T{ ##branch } } 0 fresh-bb
    V{ T{ ##add-imm { dst 2 } { src1 1 } { src2 1 } } T{ ##branch } } 2 fresh-bb
    V{ T{ ##phi { dst 1 } { inputs H{ { 0 0 } { 2 2 } } } } T{ ##branch } } 1 fresh-bb
    0 1 edge 1 2 edge 2 1 edge
    0 get block>cfg check-ssa
] unit-test
