USING: sequences vocabs.loader ;
<< {
    "compiler.cfg.liveness"
    "compiler.cfg.linear-scan.assignment"
    "compiler.cfg.linear-scan"
    "compiler.cfg.register-allocation.ssa"
    "compiler.cfg.register-allocation.ssa.bases"
    "compiler.cfg.register-allocation.chordal.bases"
    "compiler.cfg.register-allocation"
    "compiler.cfg.register-allocation.ssa.phases"
    "compiler.cfg.register-allocation.verifier"
} [ reload ] each >>
USING: kernel namespaces sequences tools.test ;
"compiler.cfg.register-allocation.verifier" test
:test-failures test-failures get empty? t assert=
"/tmp/allocator-call-clobber-negative.factor" run-file
