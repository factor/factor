! Final candidate: the ssa.bases suite includes 16 moving-pointer CFGs,
! 384 fresh object pairs, all four public kernels and rematerialization ±.
USING: vocabs.loader sequences ;
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
    "compiler.cfg.register-allocation.validation"
    "compiler.cfg.register-allocation.greedy"
    "compiler.cfg.register-allocation.backtracking"
    "compiler.cfg.register-allocation.chordal"
} [ reload ] each >>
USING: kernel namespaces sequences tools.test ;
"compiler.cfg.register-allocation.ssa.bases" test
:test-failures test-failures get empty? t assert=
