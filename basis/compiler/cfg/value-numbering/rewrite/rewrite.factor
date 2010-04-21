! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel compiler.cfg.instructions ;
IN: compiler.cfg.value-numbering.rewrite

! Outputs f to mean no change
GENERIC: rewrite ( insn -- insn/f )

M: insn rewrite drop f ;
