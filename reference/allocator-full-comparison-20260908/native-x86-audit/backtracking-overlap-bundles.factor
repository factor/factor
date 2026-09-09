USING: parser vocabs.loader ;
<< "compiler.cfg.register-allocation.verifier" require
"compiler.cfg.register-allocation.verifier.rematerialization" require >>
USING: accessors arrays compiler compiler.units compiler.cfg.linear-scan.allocation.state
compiler.cfg.register-allocation compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.greedy compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.spill-sites compiler.cfg.value-numbering compiler.cfg.linear-scan.checker
combinators continuations io kernel namespaces prettyprint prettyprint.config quotations sequences tools.annotations ;
IN: allocator-backtracking-overlap-probe
backtracking-allocator register-allocator set
t check-allocation? set
t rematerialize-constants? set
t backtracking-loop-spills? set
f global-value-numbering? set
f length-limit set f nesting-limit set
\ check-allocated-intervals [ [
 "BUNDLE MEMBERS" print
 assigned-bundles get [ intervals>> [ [ vreg>> ] [ reg>> ] [ ranges>> ] tri 3array ] map . ] each
] prepose ] annotate
[ \ local-split-plan 1array compile "PASS" print ]
[ "FAIL" print . ] recover
