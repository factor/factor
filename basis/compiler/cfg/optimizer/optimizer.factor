! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.cfg.tco
compiler.cfg.useless-conditionals
compiler.cfg.branch-splitting
compiler.cfg.block-joining
compiler.cfg.height
compiler.cfg.ssa.construction
compiler.cfg.alias-analysis
compiler.cfg.value-numbering
compiler.cfg.copy-prop
compiler.cfg.dce
kernel sequences ;
IN: compiler.cfg.optimizer

: optimize-cfg ( cfg -- cfg' )
    dup {
        optimize-tail-calls
        delete-useless-conditionals
        split-branches
        join-blocks
        normalize-height
        construct-ssa
        alias-analysis
        value-numbering
        copy-propagation
        eliminate-dead-code
    } [ execute( x -- ) ] with each ;
