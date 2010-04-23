! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel compiler.constants compiler.cfg.hats
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.stacks ;
IN: compiler.cfg.intrinsics.strings

: emit-string-nth ( -- )
    2inputs swap ^^string-nth ds-push ;

: emit-set-string-nth-fast ( -- )
    3inputs ^^tagged>integer ^^add swap [ string-offset ] dip
    ##set-alien-integer-1 ;
