USING: accessors assocs compiler.cfg compiler.cfg.checker
compiler.cfg.instructions compiler.cfg.registers compiler.cfg.utilities
compiler.cfg.value-numbering compiler.cfg.value-numbering.global compiler.test cpu.architecture
kernel locals math math.bitwise namespaces sequences tools.test typed ;
IN: compiler.cfg.value-numbering.global.tests

: check-global ( cfg -- changed? )
    dup check-ssa [ global-value-numbering ] [ check-ssa ] bi ;

! A dominating expression is available in a later block.
{ t t 1 } [
    V{ T{ ##peek { dst 0 } { loc D: 0 } }
       T{ ##add-imm { dst 1 } { src1 0 } { src2 7 } }
       T{ ##branch } } 0 test-bb
    V{ T{ ##add-imm { dst 2 } { src1 0 } { src2 7 } }
       T{ ##branch } } 1 test-bb
    0 1 edge
    0 get block>cfg check-global
    1 get instructions>> first [ ##copy? ] [ src>> ] bi
] unit-test

! Equal literals participate in numbering without extending their lifetimes.
{ t t t } [
    V{ T{ ##peek { dst 0 } { loc D: 0 } }
       T{ ##load-integer { dst 1 } { val 7 } }
       T{ ##add { dst 2 } { src1 0 } { src2 1 } }
       T{ ##branch } } 0 test-bb
    V{ T{ ##load-integer { dst 3 } { val 7 } }
       T{ ##add { dst 4 } { src1 0 } { src2 3 } }
       T{ ##branch } } 1 test-bb
    0 1 edge
    0 get block>cfg check-global
    1 get instructions>> [ first ##load-integer? ] [ second ##copy? ] bi
] unit-test

! Exercise the production pipeline and execute its generated machine code.
! On ARM64, global reuse removes a repeated xor across this branch.
TYPED:: across-branch ( x: fixnum flag: boolean -- y: fixnum )
    x 7 bitxor :> a
    flag [ a 3 bitand ] [ a 1 bitand ] if
    x 7 bitxor bitxor ; inline

{ 32 34 -8 } [
    t global-value-numbering? [
        37 t [ across-branch ] compile-call
        37 f [ across-branch ] compile-call
        -1 t [ across-branch ] compile-call
    ] with-variable
] unit-test

! Neither sibling dominates the join. Preserve the phi, then use its
! available result to eliminate the congruent expression after it.
{ t t t 3 } [
    V{ T{ ##peek { dst 0 } { loc D: 0 } } T{ ##branch } } 0 test-bb
    V{ T{ ##add-imm { dst 1 } { src1 0 } { src2 7 } } T{ ##branch } } 1 test-bb
    V{ T{ ##add-imm { dst 2 } { src1 0 } { src2 7 } } T{ ##branch } } 2 test-bb
    V{ T{ ##phi { dst 3 } { inputs H{ { 1 1 } { 2 2 } } } }
       T{ ##add-imm { dst 4 } { src1 0 } { src2 7 } } T{ ##branch } } 3 test-bb
    0 { 1 2 } edges 1 3 edge 2 3 edge
    0 get block>cfg check-global
    3 get instructions>> [ first ##phi? ]
    [ second [ ##copy? ] [ src>> ] bi ] bi
] unit-test

! Without a phi there is no available register at the join.
{ f t } [
    V{ T{ ##peek { dst 0 } { loc D: 0 } } T{ ##branch } } 0 test-bb
    V{ T{ ##add-imm { dst 1 } { src1 0 } { src2 7 } } T{ ##branch } } 1 test-bb
    V{ T{ ##add-imm { dst 2 } { src1 0 } { src2 7 } } T{ ##branch } } 2 test-bb
    V{ T{ ##add-imm { dst 3 } { src1 0 } { src2 7 } } T{ ##branch } } 3 test-bb
    0 { 1 2 } edges 1 3 edge 2 3 edge
    0 get block>cfg check-global
    3 get instructions>> first ##add-imm?
] unit-test

! Phi keys must retain which value came from which predecessor.
{ f 2 } [
    V{ T{ ##peek { dst 0 } { loc D: 0 } }
       T{ ##peek { dst 1 } { loc D: 1 } } T{ ##branch } } 0 test-bb
    V{ T{ ##branch } } 1 test-bb
    V{ T{ ##branch } } 2 test-bb
    V{ T{ ##phi { dst 2 } { inputs H{ { 1 0 } { 2 1 } } } }
       T{ ##phi { dst 3 } { inputs H{ { 2 0 } { 1 1 } } } }
       T{ ##branch } } 3 test-bb
    0 { 1 2 } edges 1 3 edge 2 3 edge
    0 get block>cfg check-global
    3 get instructions>> [ ##phi? ] count
] unit-test

! A redundant phi before a useful phi must not break the phi prefix.
{ t t t } [
    V{ T{ ##peek { dst 0 } { loc D: 0 } }
       T{ ##peek { dst 1 } { loc D: 1 } } T{ ##branch } } 0 test-bb
    V{ T{ ##branch } } 1 test-bb
    V{ T{ ##branch } } 2 test-bb
    V{ T{ ##phi { dst 2 } { inputs H{ { 1 0 } { 2 0 } } } }
       T{ ##phi { dst 3 } { inputs H{ { 1 0 } { 2 1 } } } }
       T{ ##branch } } 3 test-bb
    0 { 1 2 } edges 1 3 edge 2 3 edge
    0 get block>cfg check-global
    3 get instructions>> [ first ##phi? ] [ second ##copy? ] bi
] unit-test

! An optimistic loop phi converges without allocating new registers.
{ t t } [
    V{ T{ ##peek { dst 0 } { loc D: 0 } } T{ ##branch } } 0 test-bb
    V{ T{ ##copy { dst 2 } { src 1 } { rep any-rep } } T{ ##branch } } 2 test-bb
    V{ T{ ##phi { dst 1 } { inputs H{ { 0 0 } { 2 2 } } } } T{ ##branch } } 1 test-bb
    0 1 edge 1 2 edge 2 1 edge
    0 get block>cfg check-global
    1 get instructions>> first ##copy?
] unit-test

! Calls/kill blocks prevent register availability from crossing them.
{ f t } [
    V{ T{ ##peek { dst 0 } { loc D: 0 } }
       T{ ##add-imm { dst 1 } { src1 0 } { src2 7 } } T{ ##branch } } 0 test-bb
    V{ T{ ##branch } } 1 test-bb 1 get t >>kill-block? drop
    V{ T{ ##add-imm { dst 2 } { src1 0 } { src2 7 } } T{ ##branch } } 2 test-bb
    0 1 edge 1 2 edge
    0 get block>cfg check-global
    2 get instructions>> first ##add-imm?
] unit-test

! Global equality of operands is insufficient for FP or mutable loads.
{ f t t } [
    V{ T{ ##peek { dst 0 } { loc D: 0 } }
       T{ ##integer>float { dst 1 } { src 0 } }
       T{ ##load-memory-imm { dst 2 } { base 0 } { offset 0 } { rep int-rep } }
       T{ ##branch } } 0 test-bb
    V{ T{ ##integer>float { dst 3 } { src 0 } }
       T{ ##load-memory-imm { dst 4 } { base 0 } { offset 0 } { rep int-rep } }
       T{ ##branch } } 1 test-bb
    0 1 edge
    0 get block>cfg check-global
    1 get instructions>> [ first ##integer>float? ] [ second ##load-memory-imm? ] bi
] unit-test
