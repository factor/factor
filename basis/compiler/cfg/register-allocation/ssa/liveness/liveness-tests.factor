USING: accessors assocs compiler.cfg.instructions compiler.cfg.liveness
compiler.cfg.register-allocation.ssa.liveness
compiler.cfg.ssa.destruction.leaders compiler.cfg.utilities
kernel locals namespaces sequences sorting tools.test ;
IN: compiler.cfg.register-allocation.ssa.liveness.tests

! These are fixed memory tokens with no register definitions or base-pointer
! provenance. Every explicit root remains live and the map is unmodified.
{ { 70 71 72 } t } [ [ [let
    f leader-map set
    T{ gc-map { gc-roots { 70 } } { derived-roots H{ { 71 72 } } } } :> map
    H{ } clone :> live
    live ##call-gc new map >>gc-map visit-ssa-insn-preserving-gc
    live keys sort
    map T{ gc-map { gc-roots { 70 } } { derived-roots H{ { 71 72 } } } } =
] ] with-scope ] unit-test

! Exercise the complete fixed-point driver, not only its instruction visitor.
{ { 70 71 72 } } [ [
    f leader-map set
    {
        T{ ##call-gc { gc-map T{ gc-map { gc-roots { 70 } }
            { derived-roots H{ { 71 72 } } } } } }
        T{ ##return }
    } insns>cfg dup compute-ssa-live-sets-preserving-gc
    entry>> live-in keys sort
] with-scope ] unit-test
