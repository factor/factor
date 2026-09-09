USING: accessors arrays assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.loop-detection compiler.cfg.register-allocation.chordal.spilling
compiler.cfg.registers compiler.cfg.utilities cpu.architecture kernel locals
namespaces sequences tools.test vectors ;
IN: compiler.cfg.register-allocation.validation.entry-residency.tests

:: entry-plan ( bb residents saved -- plan )
    spill-block new bb >>bb residents >>exit-versions saved >>saved-exit
        H{ { 1 1 } } clone >>distances H{ } clone >>phi-sources
        H{ } clone >>entry-versions H{ } clone >>entry-phis
        H{ } clone >>memory-phis H{ } clone >>saved-entry
        V{ } clone >>originals ;

:: entry-fixture ( -- left right join plan )
    H{ { 1 int-rep } { 2 int-rep } { 10 int-rep } }
        clone representations namespaces:set
    100 vreg-counter namespaces:set
    H{ } clone loops namespaces:set
    H{ { int-regs { 0 } } } spill-bank namespaces:set
    H{ } clone spill-plans namespaces:set
    V{ T{ ##branch } } clone 0 insns>block :> left
    V{ T{ ##branch } } clone 1 insns>block :> right
    V{ } clone 2 insns>block :> join
    left join connect-bbs right join connect-bbs
    left f f entry-plan left spill-plans get set-at
    right f f entry-plan right spill-plans get set-at
    join f f entry-plan :> plan
    plan join spill-plans get set-at
    left right join plan ;

! A processed empty predecessor is different from an unprocessed backedge.
! The latter can still supply a resident value when its body is rewritten.
{ t t } [ [ [let
    entry-fixture :> ( left right join plan )
    left spill-plans get at H{ } clone >>exit-versions drop
    join right connect-bbs
    1 plan entry-resident-candidate?
    right spill-plans get at H{ } clone >>exit-versions drop
    1 plan entry-resident-candidate? not
] ] with-scope ] unit-test

! Single-predecessor blocks inherit actual residency, including known empty.
{ t t } [ [ [let
    entry-fixture :> ( left right join plan )
    left 1vector join predecessors<<
    left spill-plans get at H{ } clone >>exit-versions drop
    plan choose-entry-values empty?
    left spill-plans get at H{ { 1 10 } } clone >>exit-versions drop
    1 plan choose-entry-values member?
] ] with-scope ] unit-test

! Phi eligibility tests the incoming source identity, not the result name.
{ t } [ [ [let
    entry-fixture :> ( left right join plan )
    left spill-plans get at H{ { 2 10 } } clone >>exit-versions drop
    right spill-plans get at H{ } clone >>exit-versions drop
    H{ } clone :> inputs
    2 left inputs set-at 1 right inputs set-at
    inputs 1 plan phi-sources>> set-at
    1 plan choose-entry-values member?
] ] with-scope ] unit-test

! One predecessor has a dirty register, the other only a valid memory home.
! The resident join must not force the dirty path to initialize a memory
! home just because the other path already saved it. Its S fact is false;
! a later eviction must store the joined register before any local reload.
{ t t t t t t } [ [ [let
    entry-fixture :> ( left right join plan )
    left spill-plans get at
        H{ { 1 10 } } clone >>exit-versions H{ } clone >>saved-exit drop
    right spill-plans get at
        H{ } clone >>exit-versions H{ { 1 t } } clone >>saved-exit drop
    H{ { 1 11 } } clone spill-homes namespaces:set
    H{ } clone spill-memory-locations namespaces:set
    0 <spill-slot> 11 spill-memory-locations get set-at
    H{ } clone spill-statistics namespaces:set
    plan make-entry-versions
    plan saved-entry>> 1 swap key? not
    left spill-plans get at plan couple-spill-edge
    right spill-plans get at plan couple-spill-edge
    left successors>> first join eq?
    right successors>> first instructions>> first ##reload?
    plan entry-versions>> clone spill-W namespaces:set
    plan saved-entry>> clone spill-S namespaces:set
    V{ } clone spill-output namespaces:set
    { 1 } H{ { 1 1 } } evict-values
    1 ensure-register
    spill-output get first2 :> ( store reload )
    store ##spill? reload ##reload? and
    store src>> 1 plan entry-versions>> at =
    store dst>> reload src>> =
] ] with-scope ] unit-test

! Unknown backedges retain the existing known-predecessor policy. Only a
! fully known join uses intersection, and a phi result never inherits its
! incoming source's memory-home identity.
{ t f t f f } [ [ [let
    entry-fixture :> ( left right join plan )
    join right connect-bbs
    left spill-plans get at H{ { 1 t } } clone >>saved-exit drop
    1 plan entry-memory-valid?
    left spill-plans get at H{ } clone >>saved-exit drop
    1 plan entry-memory-valid?
    left spill-plans get at H{ { 1 t } } clone >>saved-exit drop
    right spill-plans get at H{ { 1 t } } clone >>saved-exit drop
    1 plan entry-memory-valid?
    right spill-plans get at H{ } clone >>saved-exit drop
    1 plan entry-memory-valid?
    right spill-plans get at H{ { 1 t } } clone >>saved-exit drop
    H{ } clone 1 plan phi-sources>> set-at
    1 plan entry-memory-valid?
] ] with-scope ] unit-test
