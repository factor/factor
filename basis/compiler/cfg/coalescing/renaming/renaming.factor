! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;
IN: compiler.cfg.coalescing.renaming

: perform-renaming ( -- )
    renaming-sets get [
        ! XXX
        2drop
    ] assoc-each ;
