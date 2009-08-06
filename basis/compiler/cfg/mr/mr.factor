! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.cfg.linearization compiler.cfg.gc-checks
compiler.cfg.linear-scan compiler.cfg.build-stack-frame
compiler.cfg.rpo ;
IN: compiler.cfg.mr

: build-mr ( cfg -- mr )
    insert-gc-checks
    linear-scan
    flatten-cfg
    build-stack-frame ;