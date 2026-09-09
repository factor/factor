USING: accessors arrays assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.allocation compiler.cfg.linear-scan.checker
compiler.cfg.linear-scan.live-intervals compiler.cfg.linear-scan.numbering
compiler.cfg.register-allocation compiler.cfg.register-allocation.chordal.bases
compiler.cfg.register-allocation.ssa compiler.cfg.register-allocation.ssa.phases
compiler.cfg.register-allocation.validation compiler.cfg.registers
compiler.cfg.ssa.destruction.leaders compiler.cfg.utilities cpu.architecture
kernel layouts locals make math namespaces sequences sequences.generalizations tools.test ;
QUALIFIED: compiler.cfg.linear-scan.allocation
IN: compiler.cfg.register-allocation.ssa.phases.tests

{ { 10 11 11 11 10 10 } } [
    T{ ##add { insn# 10 } } 0 ssa-input-phase
    T{ ##add { insn# 10 } } 1 ssa-input-phase
    T{ ##add { insn# 10 } } ssa-output-phase
    T{ ##unbox-any-c-ptr { insn# 10 } } 0 ssa-input-phase
    T{ ##alien-invoke { insn# 10 } } 0 ssa-input-phase
    T{ ##alien-invoke { insn# 10 } } ssa-output-phase
    6 narray
] unit-test

: <phase-add-cfg> ( -- graph )
    init-validation-representations
    [
        ##prologue,
        0 D: 0 ##peek, 1 0 ##tagged>integer,
        2 7 tag-fixnum ##load-integer,
        3 1 2 ##add,
        3 D: 0 ##replace,
        ##epilogue, ##return,
    ] { } make insns>cfg ;

! This is an explicitly named mechanics test, not a chordal implementation.
! The reference interval allocator supplies colors to the paired phase API.
:: phase-mechanics-kernel ( graph bank -- )
    f leader-map set
    graph construct-ssa-bases graph compute-ssa-live-sets
    representations get keys [ dup ] H{ } map>assoc leader-map set
    graph number-instructions
    graph compute-phase-ssa-intervals :> intervals
    intervals required-register-uses :> expected
    intervals bank compiler.cfg.linear-scan.allocation:allocate-registers :> allocated
    allocated bank check-allocated-intervals
    allocated expected check-register-uses
    allocated [ [ spill-to>> ] [ reload-from>> ] bi or not ] all? t assert=
    graph allocated assign-phase-ssa-registers
    graph resolve-ssa-data-flow ;

{ t } [ [ [let
    <phase-add-cfg> :> graph
    graph 2 2 validation-register-bank :> bank
    linear-scan-allocator bank [ phase-mechanics-kernel ] constrained-allocator boa
    graph swap compile-validation-cfg :> word
    { -101 -7 -1 0 1 7 101 } [| input |
        input word execute( x -- y ) input 7 + =
    ] all?
] ] with-scope ] unit-test

! A split fragment reloaded at the late point can overwrite the first
! input before the machine instruction executes. Reject it before emitting.
[
    T{ ##add { insn# 10 } } 1array insns>cfg
    1 <live-interval>
        V{ { 11 11 } } >>ranges
        0 <spill-slot> >>reload-from
    1array check-phase-ssa-transports
] [ unsafe-late-ssa-reload? ] must-fail-with

! The def-is-use instruction retains both its input/output conflict and a
! scratch interval spanning both phases, despite ordinary first-use reuse.
{ V{ { 0 11 } } V{ { 11 11 } } V{ { 10 11 } } } [ [
    init-validation-representations
    H{ { 0 0 } { 1 1 } { 2 2 } } clone leader-map set
    H{ } clone live-intervals set
    0 from set
    T{ ##box-alien { insn# 10 } { src 0 } { dst 1 } { temp 2 } }
    compute-phase-insn-intervals
    0 live-intervals get at ranges>>
    1 live-intervals get at ranges>>
    2 live-intervals get at ranges>>
] with-scope ] unit-test

! ABI memory operands remain at the original synchronization point, and
! carry the spill-slot flag for both hairy-clobber inputs and outputs.
{ 10 t 10 t } [ [
    init-validation-representations
    H{ { 0 0 } { 1 1 } } clone leader-map set
    H{ } clone live-intervals set
    0 from set
    T{ ##alien-invoke { insn# 10 }
        { reg-inputs { { 0 int-rep 0 } } } { stack-inputs { } }
        { reg-outputs { { 1 int-rep 0 } } }
        { gc-map T{ gc-map { gc-roots V{ } } { derived-roots H{ } } } } }
    compute-phase-insn-intervals
    0 live-intervals get at uses>> first [ n>> ] [ spill-slot?>> ] bi
    1 live-intervals get at uses>> first [ n>> ] [ spill-slot?>> ] bi
] with-scope ] unit-test
