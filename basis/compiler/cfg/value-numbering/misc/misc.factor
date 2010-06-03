! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors cpu.architecture kernel
compiler.cfg.instructions
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.rewrite ;
IN: compiler.cfg.value-numbering.misc

M: ##replace rewrite
    [ loc>> ] [ src>> vreg>insn ] bi
    dup literal-insn? [
        insn>literal dup immediate-store?
        [ swap \ ##replace-imm new-insn ] [ 2drop f ] if
    ] [ 2drop f ] if ;
