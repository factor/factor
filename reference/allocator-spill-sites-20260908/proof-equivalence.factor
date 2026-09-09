! Fresh-process diagnostic: compare both finishing rules on identical
! allocated records before assignment, avoiding allocator tie/order noise.
USING: accessors assocs compiler.cfg.linear-scan.live-intervals
compiler.cfg.register-allocation.spill-sites
compiler.cfg.register-allocation.spill-sites.fixtures kernel locals
namespaces prettyprint sequences tools.test words ;
IN: compiler.cfg.register-allocation.spill-sites.proof-equivalence

SYMBOL: corrected-finish
SYMBOL: comparison-count
<<
\ finish-loop-spills def>> \ corrected-finish set-global
H{ { "checked" 0 } } clone \ comparison-count set-global
>>

:: former-redundant-spill? ( interval -- ? )
    interval vreg>> cold-spill-values get key?
    interval spill-to>> >boolean and
    interval reload-from>> interval spill-to>> = and
    interval reload-rep>> interval spill-rep>> eq? and
    interval uses>> [ def-rep>> ] any? not and ;

:: compare-finishes ( intervals -- intervals )
    intervals [ clone ] map :> former
    backtracking-loop-spills? get [
        former [
            dup former-redundant-spill? [ f >>spill-to ] when drop
        ] each
    ] when
    intervals corrected-finish get call( intervals -- intervals ) :> corrected
    former corrected assert=
    "checked" comparison-count get inc-at
    corrected ;

IN: compiler.cfg.register-allocation.spill-sites
: finish-loop-spills ( intervals -- intervals )
    compiler.cfg.register-allocation.spill-sites.proof-equivalence:compare-finishes ;

IN: compiler.cfg.register-allocation.spill-sites.proof-equivalence
{ { 40 40 8 5 } { 40 8 2 8 } { 40 12 4 8 }
  { 40 16 8 5 } { 24 12 4 4 } { 32 24 8 4 } }
[ dup . first4 t loop-pressure-metrics* 2drop ] each
comparison-count get .
