! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs cpu.architecture grouping kernel
sequences
compiler.cfg.instructions
compiler.cfg.utilities
compiler.cfg.gvn.graph
compiler.cfg.gvn.rewrite ;
IN: compiler.cfg.gvn.misc

M: ##replace rewrite
    [ loc>> ] [ src>> vreg>insn ] bi
    dup literal-insn? [
        insn>literal dup immediate-store?
        [ swap \ ##replace-imm new-insn ] [ 2drop f ] if
    ] [ 2drop f ] if ;

! XXX any particular input's vn isn't necessarily available, so
!     can't just return a straight-up <copy>; might just do
!     this with a set-vn in gvn.factor:value-number
M: ##phi rewrite
    [ dst>> ] [ inputs>> values [ vreg>vn ] map sift ] bi
    dup all-equal? [
        [ drop f ]
        [ first <copy> ] if-empty
    ] [ 2drop f ] if ;
