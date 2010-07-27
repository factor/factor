! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel compiler.cfg.representations
compiler.cfg.scheduling compiler.cfg.gc-checks
compiler.cfg.save-contexts compiler.cfg.ssa.destruction
compiler.cfg.build-stack-frame compiler.cfg.linear-scan
compiler.cfg.stacks.uninitialized compiler.cfg.block-joining ;
IN: compiler.cfg.finalization

: finalize-cfg ( cfg -- cfg' )
    select-representations
    schedule-instructions
    insert-gc-checks
    dup compute-uninitialized-sets
    insert-save-contexts
    destruct-ssa
    linear-scan
    join-blocks
    build-stack-frame ;
