! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors combinators namespaces
compiler.cfg.tco
compiler.cfg.predecessors
compiler.cfg.useless-conditionals
compiler.cfg.stack-analysis
compiler.cfg.dcn
compiler.cfg.dominance
compiler.cfg.ssa
compiler.cfg.branch-splitting
compiler.cfg.block-joining
compiler.cfg.alias-analysis
compiler.cfg.value-numbering
compiler.cfg.dce
compiler.cfg.write-barrier
compiler.cfg.liveness
compiler.cfg.rpo
compiler.cfg.phi-elimination
compiler.cfg.checker ;
IN: compiler.cfg.optimizer

SYMBOL: check-optimizer?

: ?check ( cfg -- cfg' )
    check-optimizer? get [
        dup check-cfg
    ] when ;

SYMBOL: new-optimizer?

: optimize-cfg ( cfg -- cfg' )
    ! Note that compute-predecessors has to be called several times.
    ! The passes that need this document it.
    [
        optimize-tail-calls
        new-optimizer? get [ delete-useless-conditionals ] unless
        compute-predecessors
        new-optimizer? get [ split-branches ] unless
        new-optimizer? get [
            deconcatenatize
            compute-dominance
            construct-ssa
        ] when
        join-blocks
        compute-predecessors
        new-optimizer? get [ stack-analysis ] unless
        compute-liveness
        alias-analysis
        value-numbering
        compute-predecessors
        eliminate-dead-code
        eliminate-write-barriers
        eliminate-phis
        ?check
    ] with-scope ;
