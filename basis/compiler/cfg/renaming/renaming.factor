! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel namespaces sequences
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.renaming.functor ;
IN: compiler.cfg.renaming

SYMBOL: renamings

: rename-value ( vreg -- vreg' )
    renamings get ?at drop ;

RENAMING: rename [ rename-value ] [ rename-value ] [ drop next-vreg ]
