! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING:
compiler.cfg.alias-analysis
compiler.cfg.block-joining
compiler.cfg.branch-splitting
compiler.cfg.checker
compiler.cfg.copy-prop
compiler.cfg.dce
compiler.cfg.multiply-negate
compiler.cfg.ssa.construction
compiler.cfg.tco
compiler.cfg.useless-conditionals
compiler.cfg.utilities
compiler.cfg.value-numbering
kernel sequences ;
IN: compiler.cfg.optimizer

: optimize-ssa ( cfg -- )
    dup \ construct-ssa checked-ssa-pass
    dup \ alias-analysis checked-ssa-pass
    dup \ value-numbering checked-ssa-pass
    dup \ copy-propagation checked-ssa-pass
    dup \ fuse-multiply-negate checked-ssa-pass
    \ eliminate-dead-code checked-ssa-pass ;

: optimize-cfg ( cfg -- )
    {
        optimize-tail-calls
        delete-useless-conditionals
        split-branches
        join-blocks
        optimize-ssa
    } apply-passes ;
