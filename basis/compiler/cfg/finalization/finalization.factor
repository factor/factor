! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.cfg.build-stack-frame compiler.cfg.gc-checks
compiler.cfg.linear-scan compiler.cfg.representations
compiler.cfg.save-contexts compiler.cfg.ssa.destruction
compiler.cfg.stacks.clearing compiler.cfg.stacks.vacant compiler.cfg.utilities
compiler.cfg.write-barrier ;
IN: compiler.cfg.finalization

: finalize-cfg ( cfg -- )
    {
        select-representations
        insert-gc-checks
        eliminate-write-barriers
        clear-uninitialized
        fill-gc-maps
        insert-save-contexts
        destruct-ssa
        linear-scan
        build-stack-frame
    } apply-passes ;
