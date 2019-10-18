! Copyright (C) 2010 Slava Pestov, 2011 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit cpu.architecture fry
kernel math
compiler.cfg.instructions
compiler.cfg.gvn.graph
compiler.cfg.gvn.avail
compiler.cfg.gvn.rewrite ;
IN: compiler.cfg.gvn.slots

: simplify-slot-addressing? ( insn -- ? )
    complex-addressing? [
        slot>> vreg>insn [ ##add-imm? ] with-available-uses?
    ] [ drop f ] if ;

: simplify-slot-addressing ( insn -- insn/f )
    dup simplify-slot-addressing? [
        clone dup slot>> vreg>insn
        [ src1>> >>slot ]
        [ src2>> over scale>> '[ _ _ shift - ] change-tag ]
        bi
    ] [ drop f ] if ;

M: ##slot rewrite simplify-slot-addressing ;
M: ##set-slot rewrite simplify-slot-addressing ;
M: ##write-barrier rewrite simplify-slot-addressing ;
