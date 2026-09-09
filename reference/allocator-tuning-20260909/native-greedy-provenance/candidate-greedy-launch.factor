USING: vocabs.loader ;
<< "compiler.cfg.register-allocation.greedy" reload >>
USING: compiler.cfg.checker compiler.cfg.linear-scan.allocation.state
compiler.cfg.register-allocation.rematerialization compiler.cfg.register-allocation.spill-sites
compiler.cfg.register-allocation.verifier compiler.cfg.value-numbering namespaces parser ;
t check-allocation? set-global
t check-ssa? set-global
f global-value-numbering? set-global
t rematerialize-constants? set-global
t backtracking-loop-spills? set-global
<< "reference/allocator-tuning-20260909/greedy-provenance.factor" run-file >>

USING: alien alien.data arrays io io.encodings.binary io.files kernel math prettyprint sequences words ;
IN: allocator-greedy-provenance
V{ } clone provenance-records set
provenance-allocator register-allocator [
    \ integer-pressure 1array compile
    32 <iota> [ dup integer-pressure swap 40 * 820 + assert= ] each
    \ integer-pressure word-code over - swap <alien> swap memory>byte-array
    [ length "CODE-BYTES " write . ] keep
    "reference/allocator-tuning-20260909/greedy-code.bin" binary set-file-contents
    provenance-records get [ >json print ] each
] with-variable
