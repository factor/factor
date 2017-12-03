! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.instructions.syntax
compiler.cfg.registers compiler.cfg.renaming.functor
generic.parser kernel namespaces sequences sets words ;
IN: compiler.cfg.renaming

SYMBOL: renamings

: rename-value ( vreg -- vreg' )
    renamings get ?at drop ;

RENAMING: rename "[ rename-value ]" "[ rename-value ]" "[ drop next-vreg ]"
