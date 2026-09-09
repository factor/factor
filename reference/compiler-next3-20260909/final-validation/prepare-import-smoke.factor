USING: parser vocabs vocabs.loader vocabs.refresh ;
<< "compiler.cfg.loop-optimization" require
   "compiler.cfg.memory-optimization" require
   "compiler.cfg.slp" require
   "compiler.cfg.representations.selection" reload
   "compiler.cfg.optimizer" reload
   refresh-all
   "reference/compiler-next3-20260909/features.factor" run-file
   "reference/compiler-next3-20260909/witnesses.factor" run-file >>
USING: allocator-runtime-comparison assocs compiler-next3.benchmark
compiler.cfg.register-allocation compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.spill-sites compiler.cfg.value-numbering
compiler.errors kernel locals math.parser memory namespaces sequences vocabs words ;
linear-scan-allocator register-allocator set-global
f global-value-numbering? set-global
f rematerialize-constants? set-global
f backtracking-loop-spills? set-global
reset-features-global
global-feature-options values [ f assert= ] each
compiler-errors get assoc-size 0 assert=
benchmark-runtime-workloads length 30 assert=
benchmark-metric-workloads length 16 assert=
prepare-selected-closure
H{ } clone
"prepared-scope" "kind" pick set-at
global-feature-options "features" pick set-at
benchmark-words get-global [ [ word-id ] [ number>string ] bi* "|" glue ] map-index "words" pick set-at
benchmark-runtime-workloads [ word-id ] map "runtime-words" pick set-at
benchmark-metric-workloads [ word-id ] map "metric-words" pick set-at emit
"reference/compiler-next3-20260909/prepare-import-smoke.image" save-image-and-exit
