! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING:
compiler.cfg.alias-analysis
compiler.cfg.block-joining
compiler.cfg.branch-splitting
compiler.cfg.copy-prop
compiler.cfg.dce
compiler.cfg.ssa.construction
compiler.cfg.tco
compiler.cfg.useless-conditionals
compiler.cfg.utilities
compiler.cfg.value-numbering
kernel sequences ;
IN: compiler.cfg.optimizer

: optimize-cfg ( cfg -- )
    {
        optimize-tail-calls
        delete-useless-conditionals
        split-branches
        join-blocks
        construct-ssa
        alias-analysis
        value-numbering
        copy-propagation
        eliminate-dead-code
    } apply-passes ;
