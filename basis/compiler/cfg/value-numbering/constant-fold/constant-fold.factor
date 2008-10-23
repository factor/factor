! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.expressions ;
IN: compiler.cfg.value-numbering.constant-fold

GENERIC: constant-fold ( insn -- insn' )

M: vop constant-fold ;

: expr>insn ( out constant-expr -- constant-op )
    [ value>> ] [ op>> ] bi new swap >>value swap >>out ;

M: pure-op constant-fold
    dup out>>
    dup vreg>expr
    dup constant-expr? [ expr>insn nip ] [ 2drop ] if ;
