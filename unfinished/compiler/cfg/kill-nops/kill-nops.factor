! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel compiler.vops ;
IN: compiler.cfg.kill-nops

! Smallest compiler pass ever.

: kill-nops ( instructions -- instructions' )
    [ nop? not ] filter ;
