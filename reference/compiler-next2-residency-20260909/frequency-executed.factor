! Untimed diagnostic: compare every production query with the old algorithm.
USING: vocabs.refresh ;
<< refresh-all >>
USING: accessors arrays assocs compiler.cfg.checker
compiler.cfg.linear-scan.allocation.state compiler.cfg.metrics
compiler.cfg.register-allocation compiler.cfg.register-allocation.chordal
compiler.cfg.register-allocation.chordal.spilling.residency
compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.verifier compiler.cfg.value-numbering
io json kernel locals math math.order namespaces parser sequences sets
sorting words ;
<< "reference/allocator-speed-crossarch-20260908/workloads.factor" run-file
   "reference/allocator-speed-crossarch-20260908/pressure.factor" run-file >>
USE: allocator-runtime-comparison
IN: compiler.cfg.register-allocation.chordal.spilling.residency
SYMBOL: saved-pressure-query
SYMBOL: pressure-query-counts
<< \ pressure-victims def>> \ saved-pressure-query set-global >>
:: reference-pressure-query ( residents demanded distances capacity -- victims )
    demanded members :> protected
    protected length capacity >
    [ protected capacity impossible-register-pressure ] when
    residents protected union length capacity - 0 max :> excess
    residents protected diff
    [ distances eviction-priority ] sort-by <reversed> excess head ;
:: pressure-victims ( residents demanded distances capacity -- victims )
    residents demanded distances capacity saved-pressure-query get
    call( residents demanded distances capacity -- victims ) :> victims
    residents demanded distances capacity reference-pressure-query victims assert=
    "queries" pressure-query-counts get inc-at
    victims empty? [
        "zero-pressure" pressure-query-counts get inc-at
        residents demanded diff length
        "unneeded-priority-entries" pressure-query-counts get [ 0 or + ] change-at
    ] when
    victims ;
IN: compiler-next2.residency.frequency
chordal-allocator register-allocator set-global
f global-value-numbering? set-global
t check-allocation? set-global
t check-ssa? set-global
t rematerialize-constants? set-global
value-flow-verifier-enabled? t assert=
H{ } clone pressure-query-counts set-global
metric-workloads [ measure-compilation drop ] each
pressure-query-counts get dup "queries" swap at 0 > t assert=
>json print
"RESIDENCY-FREQUENCY PASS" print
0 exit
