! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel namespaces sequences
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.renaming.functor ;
IN: compiler.cfg.renaming

SYMBOL: renamings

: rename-value ( vreg -- vreg' )
    renamings get ?at drop ;

RENAMING: rename [ rename-value ] [ rename-value ]

: fresh-vreg ( vreg -- vreg' )
    reg-class>> next-vreg ;

GENERIC: fresh-insn-temps ( insn -- )

M: ##write-barrier fresh-insn-temps
    [ fresh-vreg ] change-card#
    [ fresh-vreg ] change-table
    drop ;

M: ##unary/temp fresh-insn-temps
    [ fresh-vreg ] change-temp drop ;

M: ##allot fresh-insn-temps
    [ fresh-vreg ] change-temp drop ;

M: ##dispatch fresh-insn-temps
    [ fresh-vreg ] change-temp drop ;

M: ##slot fresh-insn-temps
    [ fresh-vreg ] change-temp drop ;

M: ##set-slot fresh-insn-temps
    [ fresh-vreg ] change-temp drop ;

M: ##string-nth fresh-insn-temps
    [ fresh-vreg ] change-temp drop ;

M: ##set-string-nth-fast fresh-insn-temps
    [ fresh-vreg ] change-temp drop ;

M: ##compare fresh-insn-temps
    [ fresh-vreg ] change-temp drop ;

M: ##compare-imm fresh-insn-temps
    [ fresh-vreg ] change-temp drop ;

M: ##compare-float fresh-insn-temps
    [ fresh-vreg ] change-temp drop ;

M: ##gc fresh-insn-temps
    [ fresh-vreg ] change-temp1
    [ fresh-vreg ] change-temp2
    drop ;

M: _dispatch fresh-insn-temps
    [ fresh-vreg ] change-temp drop ;

M: insn fresh-insn-temps drop ;