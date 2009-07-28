! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors combinators namespaces
compiler.cfg.tco
compiler.cfg.useless-conditionals
compiler.cfg.branch-splitting
compiler.cfg.block-joining
compiler.cfg.ssa.construction
compiler.cfg.alias-analysis
compiler.cfg.value-numbering
compiler.cfg.copy-prop
compiler.cfg.dce
compiler.cfg.write-barrier
compiler.cfg.ssa.destruction
compiler.cfg.empty-blocks
compiler.cfg.predecessors
compiler.cfg.rpo
compiler.cfg.checker ;
IN: compiler.cfg.optimizer

SYMBOL: check-optimizer?

: ?check ( cfg -- cfg' )
    check-optimizer? get [
        dup check-cfg
    ] when ;

: optimize-cfg ( cfg -- cfg' )
    ! Note that compute-predecessors has to be called several times.
    ! The passes that need this document it.
    [
        optimize-tail-calls
        delete-useless-conditionals
        compute-predecessors
        split-branches
        join-blocks
        compute-predecessors
        construct-ssa
        alias-analysis
        value-numbering
        compute-predecessors
        copy-propagation
        eliminate-dead-code
        eliminate-write-barriers
        destruct-ssa
        delete-empty-blocks
        ?check
    ] with-scope ;
