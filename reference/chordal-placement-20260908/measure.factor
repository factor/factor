USING: vocabs.loader vocabs.refresh ;
<< "compiler.cfg.register-allocation" reload
   "compiler.cfg.register-allocation.chordal" reload >>
USING: compiler.cfg.register-allocation.verifier ;
USING: command-line benchmark.spectral-norm benchmark.nbody benchmark.fannkuch benchmark.binary-trees accessors assocs compiler.cfg.metrics compiler.cfg.register-allocation compiler.cfg.register-allocation.chordal compiler.cfg.linear-scan.allocation.state compiler.cfg.value-numbering io json kernel namespaces sequences words ;
IN: chordal-measure
"linear-scan" command-line get member?
[ linear-scan-allocator ] [ chordal-allocator ] if register-allocator set
t check-allocation? set
value-flow-verifier-enabled? [ ] [ "verifier-disabled" throw ] if
f global-value-numbering? set
{
{ "mismatch" "sequences" }
{ "rehash" "hashtables" }
{ "post-order" "compiler.cfg.rpo" }
{ "compute-def-use" "compiler.tree.def-use" }
{ "build-stack-frame" "compiler.cfg.build-stack-frame" }
{ "linear-scan" "compiler.cfg.linear-scan" }
{ "propagate" "compiler.tree.propagation" }
{ "build-tree" "compiler.tree.builder" }
{ "generate" "compiler.codegen" }
{ "spectral-norm" "benchmark.spectral-norm" }
{ "nbody" "benchmark.nbody" }
{ "fannkuch" "benchmark.fannkuch" }
{ "binary-trees-benchmark" "benchmark.binary-trees" }
} [ first2 lookup-word measure-compilation >json print flush ] each
