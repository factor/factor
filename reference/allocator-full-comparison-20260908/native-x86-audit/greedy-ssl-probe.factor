USING: parser vocabs vocabs.loader ;
<< "compiler.cfg.linear-scan.assignment" reload
"compiler.cfg.register-allocation.greedy" reload
"compiler.cfg.register-allocation.verifier" require
"compiler.cfg.register-allocation.verifier.rematerialization" require >>
USING: arrays classes.struct compiler compiler.cfg.linear-scan.allocation.state
compiler.cfg.register-allocation compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.rematerialization compiler.cfg.register-allocation.spill-sites
compiler.cfg.value-numbering compiler.units generic io kernel namespaces openssl.libssl
prettyprint sequences ;
IN: allocator-greedy-ssl-probe

greedy-allocator register-allocator set
t check-allocation? set
t backtracking-loop-spills? set
f global-value-numbering? set
{ f t } [
    dup rematerialize-constants? set
    "SSL method rematerialization=" write .
    SSL \ struct-slot-values ?lookup-method 1array compile
    "SSL method checked compilation passed" print
] each
