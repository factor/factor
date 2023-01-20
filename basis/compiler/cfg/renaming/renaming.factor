! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs compiler.cfg.registers
compiler.cfg.renaming.functor kernel namespaces ;
IN: compiler.cfg.renaming

SYMBOL: renamings

: rename-value ( vreg -- vreg' )
    renamings get ?at drop ;

RENAMING: rename [ rename-value ] [ rename-value ] [ drop next-vreg ]
