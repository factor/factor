USING: parser vocabs.loader ;
<< "compiler.cfg.register-allocation.verifier" require
"compiler.cfg.register-allocation.verifier.rematerialization" require >>
USING: compiler compiler.cfg.linear-scan.allocation.state
compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.spill-sites compiler.cfg.value-numbering
io kernel namespaces quotations sequences tools.annotations ;
IN: allocator-runtime-comparison
: trace-compiling ( word -- word ) dup word-id "TRACE: " prepend print flush ;
\ compile-word [ [ trace-compiling ] prepose ] annotate
"backtracking" select-allocator
t rematerialize-constants? set
t backtracking-loop-spills? set
f global-value-numbering? set
t check-allocation? set
benchmark-words get-global compile
