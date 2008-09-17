! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel compiler.vops compiler.cfg.vn.graph
compiler.cfg.vn.expressions ;
IN: compiler.cfg.vn.constant-fold

GENERIC: constant-fold ( insn -- insn' )

M: vop constant-fold ;

: expr>insn ( out constant-expr -- constant-op )
    [ value>> ] [ op>> ] bi new swap >>value swap >>out ;

M: pure-op constant-fold
    dup out>>
    dup vreg>vn vn>expr
    dup constant-expr? [ expr>insn nip ] [ 2drop ] if ;
