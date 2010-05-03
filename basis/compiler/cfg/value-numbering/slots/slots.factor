! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit cpu.architecture fry
kernel math
compiler.cfg.instructions
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.rewrite ;
IN: compiler.cfg.value-numbering.slots

: simplify-slot-addressing? ( insn -- ? )
    complex-addressing?
    [ slot>> vreg>insn ##add-imm? ] [ drop f ] if ;

: simplify-slot-addressing ( insn -- insn/f )
    dup simplify-slot-addressing? [
        dup slot>> vreg>insn
        [ src1>> >>slot ]
        [ src2>> over scale>> '[ _ _ shift - ] change-tag ]
        bi
    ] [ drop f ] if ;

M: ##slot rewrite simplify-slot-addressing ;
M: ##set-slot rewrite simplify-slot-addressing ;
M: ##write-barrier rewrite simplify-slot-addressing ;
