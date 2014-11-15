! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel compiler.cfg.representations
compiler.cfg.scheduling compiler.cfg.gc-checks
compiler.cfg.write-barrier compiler.cfg.save-contexts
compiler.cfg.ssa.destruction compiler.cfg.build-stack-frame
compiler.cfg.linear-scan compiler.cfg.stacks.vacant ;
IN: compiler.cfg.finalization

: finalize-cfg ( cfg -- cfg' )
    select-representations
    schedule-instructions
    insert-gc-checks
    eliminate-write-barriers
    dup compute-vacant-sets
    insert-save-contexts
    destruct-ssa
    linear-scan
    build-stack-frame ;
