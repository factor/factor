! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.cfg.gc-checks compiler.cfg.representations
compiler.cfg.save-contexts compiler.cfg.ssa.destruction
compiler.cfg.build-stack-frame compiler.cfg.linear-scan ;
IN: compiler.cfg.finalization

: finalize-cfg ( cfg -- cfg' )
    select-representations
    insert-gc-checks
    insert-save-contexts
    destruct-ssa
    linear-scan
    build-stack-frame ;
