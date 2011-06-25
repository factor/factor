! Copyright (C) 2011 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg
compiler.cfg.dataflow-analysis compiler.cfg.def-use hashtables
kernel namespaces sequences ;
IN: compiler.cfg.gvn.avail

! assoc mapping basic blocks to the set of value numbers that
! are defined in the block
SYMBOL: bbs>defns

! : defined ( bb -- vns ) bbs>defns get at ;

: defined ( bb -- vregs )
    instructions>> [ defs-vregs ] map concat [ dup ] H{ } map>assoc ;

FORWARD-ANALYSIS: avail

M: avail-analysis transfer-set drop defined assoc-union ;

: available? ( vn -- ? )
    basic-block get avail-ins get at key? ;

: make-available ( insn -- insn )
    dup dst>>
    basic-block get avail-ins get [ dupd ?set-at ] change-at ;
