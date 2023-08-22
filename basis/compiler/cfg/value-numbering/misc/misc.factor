! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg.instructions
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.rewrite cpu.architecture kernel ;
IN: compiler.cfg.value-numbering.misc

M: ##replace rewrite
    [ loc>> ] [ src>> vreg>insn ] bi
    dup literal-insn? [
        insn>literal dup immediate-store?
        [ swap ##replace-imm new-insn ] [ 2drop f ] if
    ] [ 2drop f ] if ;
