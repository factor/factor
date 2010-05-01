! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg.instructions
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.rewrite cpu.architecture kernel ;
IN: compiler.cfg.value-numbering.misc

M: ##replace rewrite
    object-immediates? [
        [ loc>> ] [ src>> vreg>insn ] bi dup literal-insn?
        [ insn>literal swap \ ##replace-imm new-insn ]
        [ 2drop f ] if
    ] [ drop f ] if ;
