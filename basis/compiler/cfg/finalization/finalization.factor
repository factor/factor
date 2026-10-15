! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: compiler.cfg.build-stack-frame compiler.cfg.gc-checks
compiler.cfg.register-allocation compiler.cfg.representations
compiler.cfg.save-contexts
compiler.cfg.stacks.clearing compiler.cfg.utilities
compiler.cfg.write-barrier cpu.architecture ;
IN: compiler.cfg.finalization

: finalize-cfg ( cfg -- )
    {
        select-representations
        lower-native-helpers
        insert-gc-checks
        eliminate-write-barriers
        clear-uninitialized
        insert-save-contexts
        allocate-registers
        build-stack-frame
    } apply-passes ;
