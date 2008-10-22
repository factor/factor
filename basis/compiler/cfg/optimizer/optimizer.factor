! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.cfg.rpo compiler.cfg.height
compiler.cfg.alias-analysis compiler.cfg.write-barrier ;
IN: compiler.cfg.optimizer

: optimize-cfg ( cfg -- cfg' )
    [
        normalize-height
        alias-analysis
        eliminate-write-barriers
    ] change-basic-blocks ;
