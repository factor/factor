! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel namespaces sequences
compiler.cfg.instructions compiler.cfg.registers ;
IN: compiler.cfg.renaming

SYMBOL: renamings

: rename-value ( vreg -- vreg' ) renamings get ?at drop ;

GENERIC: rename-insn-defs ( insn -- )

M: ##flushable rename-insn-defs
    [ rename-value ] change-dst
    drop ;

M: ##fixnum-overflow rename-insn-defs
    [ rename-value ] change-dst
    drop ;

M: _fixnum-overflow rename-insn-defs
    [ rename-value ] change-dst
    drop ;

M: insn rename-insn-defs drop ;

GENERIC: rename-insn-uses ( insn -- )

M: ##effect rename-insn-uses
    [ rename-value ] change-src
    drop ;

M: ##unary rename-insn-uses
    [ rename-value ] change-src
    drop ;

M: ##binary rename-insn-uses
    [ rename-value ] change-src1
    [ rename-value ] change-src2
    drop ;

M: ##binary-imm rename-insn-uses
    [ rename-value ] change-src1
    drop ;

M: ##slot rename-insn-uses
    [ rename-value ] change-obj
    [ rename-value ] change-slot
    drop ;

M: ##slot-imm rename-insn-uses
    [ rename-value ] change-obj
    drop ;

M: ##set-slot rename-insn-uses
    dup call-next-method
    [ rename-value ] change-obj
    [ rename-value ] change-slot
    drop ;

M: ##string-nth rename-insn-uses
    [ rename-value ] change-obj
    [ rename-value ] change-index
    drop ;

M: ##set-string-nth-fast rename-insn-uses
    dup call-next-method
    [ rename-value ] change-obj
    [ rename-value ] change-index
    drop ;

M: ##set-slot-imm rename-insn-uses
    dup call-next-method
    [ rename-value ] change-obj
    drop ;

M: ##alien-getter rename-insn-uses
    dup call-next-method
    [ rename-value ] change-src
    drop ;

M: ##alien-setter rename-insn-uses
    dup call-next-method
    [ rename-value ] change-value
    drop ;

M: ##conditional-branch rename-insn-uses
    [ rename-value ] change-src1
    [ rename-value ] change-src2
    drop ;

M: ##compare-imm-branch rename-insn-uses
    [ rename-value ] change-src1
    drop ;

M: ##dispatch rename-insn-uses
    [ rename-value ] change-src
    drop ;

M: ##fixnum-overflow rename-insn-uses
    [ rename-value ] change-src1
    [ rename-value ] change-src2
    drop ;

M: ##phi rename-insn-uses
    [ [ rename-value ] assoc-map ] change-inputs
    drop ;

M: insn rename-insn-uses drop ;

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