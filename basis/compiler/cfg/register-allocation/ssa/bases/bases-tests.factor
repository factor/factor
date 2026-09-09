USING: accessors arrays assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.allocation.state compiler.cfg.linearization compiler.cfg.liveness
compiler.cfg.register-allocation compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.greedy compiler.cfg.register-allocation.chordal
compiler.cfg.register-allocation.rematerialization compiler.cfg.register-allocation.ssa.bases
compiler.cfg.register-allocation.validation compiler.cfg.register-allocation.verifier
compiler.cfg.utilities kernel locals namespaces sequences tools.test ;
IN: compiler.cfg.register-allocation.ssa.bases.tests

! No-GC and no-phi CFGs do not run companion-base construction.
{ f f } [ [
    0 f <validation-cycle> prepare-allocation-bases
    { T{ ##call-gc { gc-map T{ gc-map } } } T{ ##return } }
    insns>cfg prepare-allocation-bases
] with-scope ] unit-test

! Preparation precedes the independent specification. It records the base
! selected on the same edge as the derived-pointer phi, and re-entry does not
! construct another set of companion phis.
{ t t t } [ [ [let
    <validation-moving-phi> :> graph
    graph prepare-allocation-bases :> context
    context bases>> 8 swap at :> base
    graph cfg>insns length :> count
    context active-allocation-base-context [
        graph construct-ssa-bases
    ] with-variable
    graph cfg>insns length count =
    context bases>> initial-base-pointers [
        graph snapshot-value-flow :> snapshot
        graph cfg>insns [ ##call-gc? ] find nip
        snapshot instructions>> at :> expected
        8 expected derived>> at base =
        base expected roots>> member?
    ] with-variable
] ] with-scope ] unit-test

! The final checker now rejects the precise omission that the native
! moving-object oracle exposed; the allocator's base map is not its oracle.
[
    [ [let
        <validation-moving-phi> :> graph
        graph 4 2 validation-register-bank :> bank
        linear-scan-allocator bank [
            linear-scan-allocation-with-registers
            cfg get cfg>insns [ ##call-gc? ] filter
            [ gc-map>> H{ } clone >>derived-roots drop ] each
        ] constrained-allocator boa
        graph swap compile-validation-cfg drop
    ] ] with-scope
] [ invalid-allocation-derived-root? ] must-fail-with

SINGLETON: base-context-recording-allocator
SYMBOL: recorded-base-context-statistic

M: base-context-recording-allocator allocate-cfg
    2drop 42 recorded-base-context-statistic set ;

! The context lifetime must not introduce a namespace that discards backend
! statistics when allocation returns. Only the base context itself restores.
{ 42 f f } [ [
    f active-allocation-base-context set
    f initial-base-pointers set
    f check-allocation? set
    base-context-recording-allocator register-allocator set
    <validation-moving-phi> allocate-registers
    recorded-base-context-statistic get
    active-allocation-base-context get initial-base-pointers get
] with-scope ] unit-test


! Different incoming heap bases and both forms of pointer phi must survive
! moving collection with an independently rooted reference on the caller's
! data stack. Reduced banks force spill traffic around the scratch operands.
{ } [ [
    {
        { linear-scan-allocator [ linear-scan-allocation-with-registers ] }
        { greedy-allocator [ greedy-allocation-with-registers ] }
        { backtracking-allocator [ backtracking-allocation-with-registers ] }
        { chordal-allocator [ chordal-allocation-with-registers ] }
    } [| pair |
        { f t } [| enabled? |
            enabled? rematerialize-constants? set
            { [ <validation-moving-tagged-phi> ] [ <validation-moving-phi> ] }
            [| constructor |
                constructor call( -- graph ) :> graph
                graph 4 2 validation-register-bank :> bank
                pair first bank pair second constrained-allocator boa
                graph swap compile-validation-cfg
                check-validation-moving-phi t assert=
            ] each
        ] each
    ] each
] with-scope ] unit-test
