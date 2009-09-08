! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors assocs kernel accessors compiler.cfg.instructions
lexer parser ;
IN: compiler.cfg.renaming.functor

FUNCTOR: define-renaming ( NAME DEF-QUOT USE-QUOT TEMP-QUOT -- )

rename-insn-defs DEFINES ${NAME}-insn-defs
rename-insn-uses DEFINES ${NAME}-insn-uses
rename-insn-temps DEFINES ${NAME}-insn-temps

WHERE

GENERIC: rename-insn-defs ( insn -- )

M: ##flushable rename-insn-defs
    DEF-QUOT change-dst
    drop ;

M: ##fixnum-overflow rename-insn-defs
    DEF-QUOT change-dst
    drop ;

M: _fixnum-overflow rename-insn-defs
    DEF-QUOT change-dst
    drop ;

M: insn rename-insn-defs drop ;

GENERIC: rename-insn-uses ( insn -- )

M: ##effect rename-insn-uses
    USE-QUOT change-src
    drop ;

M: ##unary rename-insn-uses
    USE-QUOT change-src
    drop ;

M: ##binary rename-insn-uses
    USE-QUOT change-src1
    USE-QUOT change-src2
    drop ;

M: ##binary-imm rename-insn-uses
    USE-QUOT change-src1
    drop ;

M: ##slot rename-insn-uses
    USE-QUOT change-obj
    USE-QUOT change-slot
    drop ;

M: ##slot-imm rename-insn-uses
    USE-QUOT change-obj
    drop ;

M: ##set-slot rename-insn-uses
    dup call-next-method
    USE-QUOT change-obj
    USE-QUOT change-slot
    drop ;

M: ##string-nth rename-insn-uses
    USE-QUOT change-obj
    USE-QUOT change-index
    drop ;

M: ##set-string-nth-fast rename-insn-uses
    dup call-next-method
    USE-QUOT change-obj
    USE-QUOT change-index
    drop ;

M: ##set-slot-imm rename-insn-uses
    dup call-next-method
    USE-QUOT change-obj
    drop ;

M: ##alien-getter rename-insn-uses
    dup call-next-method
    USE-QUOT change-src
    drop ;

M: ##alien-setter rename-insn-uses
    dup call-next-method
    USE-QUOT change-value
    drop ;

M: ##conditional-branch rename-insn-uses
    USE-QUOT change-src1
    USE-QUOT change-src2
    drop ;

M: ##compare-imm-branch rename-insn-uses
    USE-QUOT change-src1
    drop ;

M: ##dispatch rename-insn-uses
    USE-QUOT change-src
    drop ;

M: ##fixnum-overflow rename-insn-uses
    USE-QUOT change-src1
    USE-QUOT change-src2
    drop ;

M: ##phi rename-insn-uses
    [ USE-QUOT assoc-map ] change-inputs
    drop ;

M: insn rename-insn-uses drop ;

GENERIC: rename-insn-temps ( insn -- )

M: ##write-barrier rename-insn-temps
    TEMP-QUOT change-card#
    TEMP-QUOT change-table
    drop ;

M: ##unary/temp rename-insn-temps
    TEMP-QUOT change-temp drop ;

M: ##allot rename-insn-temps
    TEMP-QUOT change-temp drop ;

M: ##dispatch rename-insn-temps
    TEMP-QUOT change-temp drop ;

M: ##slot rename-insn-temps
    TEMP-QUOT change-temp drop ;

M: ##set-slot rename-insn-temps
    TEMP-QUOT change-temp drop ;

M: ##string-nth rename-insn-temps
    TEMP-QUOT change-temp drop ;

M: ##set-string-nth-fast rename-insn-temps
    TEMP-QUOT change-temp drop ;

M: ##box-displaced-alien rename-insn-temps
    TEMP-QUOT change-temp1
    TEMP-QUOT change-temp2
    drop ;

M: ##compare rename-insn-temps
    TEMP-QUOT change-temp drop ;

M: ##compare-imm rename-insn-temps
    TEMP-QUOT change-temp drop ;

M: ##compare-float rename-insn-temps
    TEMP-QUOT change-temp drop ;

M: ##gc rename-insn-temps
    TEMP-QUOT change-temp1
    TEMP-QUOT change-temp2
    drop ;

M: _dispatch rename-insn-temps
    TEMP-QUOT change-temp drop ;

M: insn rename-insn-temps drop ;

;FUNCTOR

SYNTAX: RENAMING: scan scan-object scan-object scan-object define-renaming ;